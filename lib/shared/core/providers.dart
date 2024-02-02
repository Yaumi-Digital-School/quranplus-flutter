import 'package:qurantafsir_flutter/main.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/services/alice_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/main_page_provider.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_group_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/user_api.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/deep_link_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/services/bookmarks_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/favorite_ayahs_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/remote_config_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/tadabbur_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/theme_state_notifier.dart';

final StateProvider<DioService> dioServiceProvider =
    StateProvider<DioService>((ref) {
  final SharedPreferenceService sharedPreferenceService =
      ref.watch(sharedPreferenceServiceProvider);
  final AliceService aliceService = ref.watch(aliceServiceProvider);

  return DioService(
    baseUrl: EnvConstants.baseUrl ?? '',
    accessToken: sharedPreferenceService.getApiToken(),
    aliceService: aliceService,
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

final Provider<HabitApi> habitApiProvider = Provider<HabitApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);

  return HabitApi(
    dioService.getDioWithAccessToken(),
  );
});

final Provider<HabitGroupApi> habitGroupApiProvider =
    Provider<HabitGroupApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);

  return HabitGroupApi(
    dioService.getDioWithAccessToken(),
  );
});

final Provider<TadabburApi> tadabburApiProvider = Provider<TadabburApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);

  return TadabburApi(
    dioService.getDioWithStaticAPIKey(),
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
  final SharedPreferenceService sharedPreferenceService =
      ref.watch(sharedPreferenceServiceProvider);
  final StateController<DioService> dioServiceNotifier =
      ref.read(dioServiceProvider.notifier);
  final AliceService aliceService = ref.watch(aliceServiceProvider);

  return AuthenticationService(
    userApi: userApi,
    sharedPreferenceService: sharedPreferenceService,
    dioServiceNotifier: dioServiceNotifier,
    aliceService: aliceService,
  );
});

final Provider<BookmarksService> bookmarksService =
    Provider<BookmarksService>((ref) {
  final BookmarkApi bookmarkApi = ref.watch(bookmarkApiProvider);

  return BookmarksService(
    bookmarkApi: bookmarkApi,
  );
});

final Provider<HabitDailySummaryService> habitDailySummaryService =
    Provider<HabitDailySummaryService>(
  (ref) {
    final SharedPreferenceService sharedPreferenceService =
        ref.watch(sharedPreferenceServiceProvider);
    final HabitApi habitApi = ref.watch(habitApiProvider);

    return HabitDailySummaryService(
      sharedPreferenceService: sharedPreferenceService,
      habitApi: habitApi,
    );
  },
);

final Provider<FavoriteAyahsService> favoriteAyahsService =
    Provider<FavoriteAyahsService>((ref) {
  // final BookmarkApi bookmarkApi = ref.watch(bookmarkApiProvider);

  return FavoriteAyahsService();
});

Provider<MainPageProvider> mainPageProvider = Provider<MainPageProvider>(
  (ref) => MainPageProvider(),
);

final Provider<DeepLinkService> deepLinkService =
    Provider<DeepLinkService>((ref) {
  final HabitGroupApi habitGroupApi = ref.watch(habitGroupApiProvider);
  final AuthenticationService auth = ref.watch(authenticationService);
  final SharedPreferenceService sharedPref =
      ref.watch(sharedPreferenceServiceProvider);
  final MainPageProvider mainPage = ref.watch(mainPageProvider);

  return DeepLinkService(
    habitGroupApi: habitGroupApi,
    authenticationService: auth,
    sharedPreferenceService: sharedPref,
    mainPageProvider: mainPage,
  );
});

final StateNotifierProvider<SettingsPageStateNotifier, SettingsPageState>
    settingsPageProvider =
    StateNotifierProvider<SettingsPageStateNotifier, SettingsPageState>(
  (StateNotifierProviderRef<SettingsPageStateNotifier, SettingsPageState> ref) {
    return SettingsPageStateNotifier(
      repository: ref.watch(authenticationService),
      sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
    );
  },
);

final StateNotifierProvider<ThemeStateNotifier, QPThemeMode> themeProvider =
    StateNotifierProvider<ThemeStateNotifier, QPThemeMode>(
  ((ref) => ThemeStateNotifier(
        sharedPreferenceService: ref.watch(
          sharedPreferenceServiceProvider,
        ),
      )),
);

final Provider<AliceService> aliceServiceProvider =
    Provider<AliceService>((ref) {
  return AliceService(navigatorKey);
});

final Provider<RemoteConfigService> remoteConfigService =
    Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

final Provider<PrayerTimesService> prayerTimesService =
    Provider<PrayerTimesService>((ref) {
  return PrayerTimesService();
});

final Provider<TadabburService> tadabburService =
    Provider<TadabburService>((ref) {
  final TadabburApi tadabburApi = ref.read(tadabburApiProvider);
  final SharedPreferenceService sp = ref.read(sharedPreferenceServiceProvider);
  final RemoteConfigService rc = ref.read(remoteConfigService);

  return TadabburService(
    tadabburApi: tadabburApi,
    sharedPreferenceService: sp,
    remoteConfigService: rc,
  );
});
