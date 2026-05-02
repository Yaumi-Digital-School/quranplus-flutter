import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_page_state_notifier.g.dart';

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

@riverpod
class SettingsPageNotifier extends _$SettingsPageNotifier {
  @override
  SettingsPageState build() {
    final sp = ref.read(sharedPreferenceServiceProvider);
    final token = sp.getApiToken();
    if (token.isEmpty) {
      return SettingsPageState(
        authenticationStatus: AuthenticationStatus.unauthenticated,
      );
    }
    return SettingsPageState(
      authenticationStatus: AuthenticationStatus.authenticated,
      token: token,
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);
    await ref.read(authenticationService).signOut();
    state = state.copyWith(
      authenticationStatus: AuthenticationStatus.unauthenticated,
      resultStatus: ResultStatus.pure,
      token: '',
    );
  }

  Future<ForceLoginParam?> getForceLoginInformation() async {
    final sp = ref.read(sharedPreferenceServiceProvider);
    final ForceLoginParam? forceLoginInfo = await sp.getForceLoginParam();
    await sp.removeForceLoginParam();
    return forceLoginInfo;
  }
}
