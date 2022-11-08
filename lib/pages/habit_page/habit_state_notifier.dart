import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';

class HabitPageState {
  HabitPageState({
    this.authenticationStatus,
    this.resultStatus = ResultStatus.pure,
    this.token = '',
    this.user = User.empty,
  });

  AuthenticationStatus? authenticationStatus;
  ResultStatus resultStatus;
  String token;
  User user;

  HabitPageState copyWith({
    AuthenticationStatus? authenticationStatus,
    ResultStatus? resultStatus,
    String? token,
    User? user,
  }) {
    return HabitPageState(
      authenticationStatus: authenticationStatus ?? this.authenticationStatus,
      resultStatus: resultStatus ?? this.resultStatus,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  bool get isLoading => authenticationStatus == null;
}

class HabitPageStateNotifier extends BaseStateNotifier<HabitPageState> {
  HabitPageStateNotifier({
    required AuthenticationService repository,
    required SharedPreferenceService sharedPreferenceService,
  })  : _repository = repository,
        _sharedPreferenceService = sharedPreferenceService,
        super(HabitPageState());

  final AuthenticationService _repository;
  final SharedPreferenceService _sharedPreferenceService;

  @override
  Future<void> initStateNotifier() async {
    _repository.initRepository();
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

  Future<void> signInWithGoogle(
    Function() onSuccess,
    Function() onError,
  ) async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    try {
      UserResponse user = await _repository.signInWithGoogle();

      if ((user.token ?? '').isEmpty) {
        state = state.copyWith(
          authenticationStatus: AuthenticationStatus.unknown,
          resultStatus: ResultStatus.canceled,
        );
      } else {
        await _setToken(user.token!);
        await _setUsername(user.data!.name);

        state = state.copyWith(
          authenticationStatus: AuthenticationStatus.authenticated,
          resultStatus: ResultStatus.success,
          token: user.token!,
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

  Future<void> _setUsername(String name) async {
    await _sharedPreferenceService.setUsername(name);
  }
}
