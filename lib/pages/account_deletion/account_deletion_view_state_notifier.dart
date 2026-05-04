import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:retrofit/retrofit.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_deletion_view_state_notifier.g.dart';

class AccountDeletionViewState {}

@riverpod
class AccountDeletionViewNotifier extends _$AccountDeletionViewNotifier {
  @override
  AccountDeletionViewState build() => AccountDeletionViewState();

  Future<bool> deleteAccount() async {
    final sp = ref.read(sharedPreferenceServiceProvider);
    final userApi = ref.read(userApiProvider);
    final auth = ref.read(authenticationService);

    HttpResponse<UserResponse> response = await userApi.deleteUser(
      token: sp.getApiToken(),
    );

    if (response.response.statusCode != 200) {
      return false;
    }

    await auth.signOut();
    await sp.removeApiToken();
    await sp.removeUsername();
    await sp.removeLastSync();
    await DbLocal().clearTableHabit();

    return true;
  }
}
