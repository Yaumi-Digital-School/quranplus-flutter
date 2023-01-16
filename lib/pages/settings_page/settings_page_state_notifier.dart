import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';

class SettingsPageState {
  SettingsPageState({
    this.authenticationStatus,
    this.resultStatus = ResultStatus.pure,
    this.token = '',
    this.user = User.empty,
  });

  AuthenticationStatus? authenticationStatus;
  ResultStatus resultStatus;
  String token;
  User user;

  SettingsPageState copyWith({
    AuthenticationStatus? authenticationStatus,
    ResultStatus? resultStatus,
    String? token,
    User? user,
  }) {
    return SettingsPageState(
      authenticationStatus: authenticationStatus ?? this.authenticationStatus,
      resultStatus: resultStatus ?? this.resultStatus,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  bool get isLoading => authenticationStatus == null;
}

class SettingsPageStateNotifier extends BaseStateNotifier<SettingsPageState> {
  SettingsPageStateNotifier({
    required AuthenticationService repository,
    required SharedPreferenceService sharedPreferenceService,
  })  : _repository = repository,
        _sharedPreferenceService = sharedPreferenceService,
        super(SettingsPageState());

  final AuthenticationService _repository;
  final SharedPreferenceService _sharedPreferenceService;
  final DbLocal _db = DbLocal();

  @override
  Future<void> initStateNotifier() async {
    _getToken();
  }

  void _getToken() {
    var token = _sharedPreferenceService.getApiToken();

    if (token.isEmpty) {
      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.unauthenticated,
      );
    } else {
      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.authenticated,
        token: token,
      );
    }
  }

  Future<void> _setToken(String token) async {
    await _sharedPreferenceService.setApiToken(token);
  }

  Future<void> _removeToken() async {
    await _sharedPreferenceService.removeApiToken();
  }

  Future<void> signInWithGoogle(
    WidgetRef ref,
    Function() onSuccess,
    Function() onError,
  ) async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    try {
      final bool isSuccess = await _repository.signInWithGoogle(ref);

      if (!isSuccess) {
        state = state.copyWith(
          authenticationStatus: AuthenticationStatus.unknown,
          resultStatus: ResultStatus.canceled,
        );

        return;
      }

      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.authenticated,
        resultStatus: ResultStatus.success,
      );
      onSuccess.call();
    } catch (_) {
      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.unauthenticated,
        resultStatus: ResultStatus.failure,
      );
      onError.call();
    }
  }

  Future<void> signOut(Function() onSuccess) async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    await _repository.signOut();
    await _removeToken();
    await _removeUsername();
    await _db.clearTableHabit();
    await _sharedPreferenceService.removeLastSync();

    state = state.copyWith(
      authenticationStatus: AuthenticationStatus.unauthenticated,
      resultStatus: ResultStatus.pure,
      token: '',
    );

    onSuccess.call();
  }

  Future<void> _setUsername(String name) async {
    await _sharedPreferenceService.setUsername(name);
  }

  Future<void> _removeUsername() async {
    await _sharedPreferenceService.removeUsername();
  }

  Future<ForceLoginParam?> getForceLoginInformation() async {
    final ForceLoginParam? forceLoginInfo =
        await _sharedPreferenceService.getForceLoginParam();
    await _sharedPreferenceService.removeForceLoginParam();

    return forceLoginInfo;
  }
}
