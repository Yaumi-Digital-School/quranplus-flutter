import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
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

  Future<void> _removeToken() async {
    await _sharedPreferenceService.removeApiToken();
  }

  Future<void> signIn({
    required Function() onSuccess,
    required Function() onAccountDeleted,
    required Function() onGeneralError,
    required SignInType type,
    required WidgetRef ref,
  }) async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    try {
      final SignInResult result = await _repository.signIn(
        type: type,
        ref: ref,
      );

      if (result == SignInResult.failedAccountDeleted) {
        state = state.copyWith(
          authenticationStatus: AuthenticationStatus.unknown,
          resultStatus: ResultStatus.canceled,
        );

        onAccountDeleted.call();

        return;
      }

      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.authenticated,
        resultStatus: ResultStatus.success,
      );
      onSuccess.call();
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getListTadabbur() method',
      );
      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.unauthenticated,
        resultStatus: ResultStatus.failure,
      );
      onGeneralError.call();
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
