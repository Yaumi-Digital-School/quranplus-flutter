import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/repositories/user_repository.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';

class SettingsPageState {
  SettingsPageState({
    this.authenticationStatus = AuthenticationStatus.unauthenticated,
    this.resultStatus = ResultStatus.pure,
    this.token = '',
    this.user = User.empty,
  });

  AuthenticationStatus authenticationStatus;
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
}

class SettingsPageStateNotifier extends BaseStateNotifier<SettingsPageState> {
  SettingsPageStateNotifier({required UserRepository repository})
      : _repository = repository,
        super(SettingsPageState());

  final UserRepository _repository;

  @override
  Future<void> initStateNotifier() async {
    _repository.initRepository();
    _getToken();
  }

  Future<void> _getToken() async {
    var token = await _repository.getToken();

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

  Future<void> signInWithGoogle(
      Function() onSuccess, Function() onError) async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    try {
      var token = await _repository.signInWithGoogle();

      if (token.isEmpty) {
        state = state.copyWith(
          authenticationStatus: AuthenticationStatus.unknown,
          resultStatus: ResultStatus.canceled,
        );
      } else {
        state = state.copyWith(
          authenticationStatus: AuthenticationStatus.authenticated,
          resultStatus: ResultStatus.success,
          token: token,
        );

        onSuccess.call();
      }
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

    state = state.copyWith(
        authenticationStatus: AuthenticationStatus.unauthenticated,
        resultStatus: ResultStatus.pure,
        token: '');

    onSuccess.call();
  }
}
