import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';

class HabitPageState {
  HabitPageState({
    this.authenticationStatus,
    this.resultStatus = ResultStatus.pure,
    this.user = User.empty,
  });

  AuthenticationStatus? authenticationStatus;
  ResultStatus resultStatus;
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

  Future<void> signIn({
    required Function() onSuccess,
    required Function() onAccountDeletedError,
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

        onAccountDeletedError.call();

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
      onGeneralError.call();
    }
  }
}
