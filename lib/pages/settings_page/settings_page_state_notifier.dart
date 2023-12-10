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

  @override
  void initStateNotifier() {
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

  Future<void> signOut() async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    await _repository.signOut();

    state = state.copyWith(
      authenticationStatus: AuthenticationStatus.unauthenticated,
      resultStatus: ResultStatus.pure,
      token: '',
    );
  }

  Future<ForceLoginParam?> getForceLoginInformation() async {
    final ForceLoginParam? forceLoginInfo =
        await _sharedPreferenceService.getForceLoginParam();
    await _sharedPreferenceService.removeForceLoginParam();

    return forceLoginInfo;
  }
}
