import 'package:qurantafsir_flutter/pages/settings_page/settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/user_api.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/services/bookmarks_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/favorite_ayahs_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';

final StateProvider<DioService> dioServiceProvider =
    StateProvider<DioService>((ref) {
  final SharedPreferenceService sharedPreferenceService =
      ref.watch(sharedPreferenceServiceProvider);

  return DioService(
    baseUrl: EnvConstants.baseUrl ?? '',
    accessToken: sharedPreferenceService.getApiToken(),
  );
});

final Provider<SharedPreferenceService> sharedPreferenceServiceProvider =
    Provider<SharedPreferenceService>((ref) {
  final SharedPreferenceService service = SharedPreferenceService();
  return service;
});

final Provider<BookmarkApi> bookmarkApiProvider = Provider<BookmarkApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);
  return BookmarkApi(
    dioService.getDioWithAccessToken(),
  );
});

final Provider<UserApi> userApiProvider =
    Provider<UserApi>((ProviderRef<UserApi> ref) {
  final DioService dioService = ref.read(dioServiceProvider);

  return UserApi(
    dioService.getDio(),
  );
});

final Provider<AuthenticationService> authenticationService =
    Provider<AuthenticationService>((ref) {
  final UserApi userApi = ref.watch(userApiProvider);

  return AuthenticationService(
    userApi: userApi,
  );
});

final Provider<BookmarksService> bookmarksService =
    Provider<BookmarksService>((ref) {
  final BookmarkApi bookmarkApi = ref.watch(bookmarkApiProvider);

  return BookmarksService(
    bookmarkApi: bookmarkApi,
  );
});

final Provider<FavoriteAyahsService> favoriteAyahsService =
    Provider<FavoriteAyahsService>((ref) {
  // final BookmarkApi bookmarkApi = ref.watch(bookmarkApiProvider);

  return FavoriteAyahsService();
});

final StateNotifierProvider<SettingsPageStateNotifier, SettingsPageState>
    settingsPageProvider =
    StateNotifierProvider<SettingsPageStateNotifier, SettingsPageState>(
        (StateNotifierProviderRef<SettingsPageStateNotifier, SettingsPageState>
            ref) {
  return SettingsPageStateNotifier(
    repository: ref.watch(authenticationService),
    sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
  );
});
