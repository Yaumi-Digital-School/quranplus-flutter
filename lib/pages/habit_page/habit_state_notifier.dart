import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart' show SignInResult;
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_state_notifier.g.dart';

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

@riverpod
class HabitPageNotifier extends _$HabitPageNotifier {
  @override
  HabitPageState build() {
    final token = ref.read(sharedPreferenceServiceProvider).getApiToken();
    if (token.isEmpty) {
      return HabitPageState(
        authenticationStatus: AuthenticationStatus.unauthenticated,
      );
    }
    return HabitPageState(
      authenticationStatus: AuthenticationStatus.authenticated,
    );
  }

  Future<void> signIn({
    required Function() onSuccess,
    required Function() onAccountDeletedError,
    required Function() onGeneralError,
    required SignInType type,
  }) async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);
    try {
      final result = await ref.read(authenticationService).signIn(type: type);
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
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on signIn() method',
      );
      state = state.copyWith(
        authenticationStatus: AuthenticationStatus.unauthenticated,
        resultStatus: ResultStatus.failure,
      );
      onGeneralError.call();
    }
  }
}
