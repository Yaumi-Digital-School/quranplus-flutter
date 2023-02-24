import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/apis/user_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class AccountDeletionViewState {}

class AccountDeletionViewStateNotifier
    extends BaseStateNotifier<AccountDeletionViewState> {
  AccountDeletionViewStateNotifier({
    required UserApi userApi,
    required SharedPreferenceService sharedPreferenceService,
    required AuthenticationService authenticationService,
  })  : _userApi = userApi,
        _authenticationService = authenticationService,
        _sharedPreferenceService = sharedPreferenceService,
        super(
          AccountDeletionViewState(),
        );

  final UserApi _userApi;
  final SharedPreferenceService _sharedPreferenceService;
  final AuthenticationService _authenticationService;

  @override
  initStateNotifier() {}

  Future<bool> deleteAccount() async {
    HttpResponse<UserResponse> response = await _userApi.deleteUser(
      token: _sharedPreferenceService.getApiToken(),
    );

    if (response.response.statusCode != 200) {
      return false;
    }

    await _authenticationService.signOut();
    await _sharedPreferenceService.removeApiToken();
    await _sharedPreferenceService.removeUsername();
    await _sharedPreferenceService.removeLastSync();
    await DbLocal().clearTableHabit();

    return true;
  }
}
