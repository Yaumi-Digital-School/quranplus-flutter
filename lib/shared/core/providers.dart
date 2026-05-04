import 'package:qurantafsir_flutter/main.dart';
import 'package:qurantafsir_flutter/shared/core/apis/city_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/services/alice_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/main_page_provider.dart';
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
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/remote_config_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/tadabbur_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// ---------------------------------------------------------------------------
// DioService — replaces the old StateProvider<DioService>
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
class DioServiceNotifier extends _$DioServiceNotifier {
  @override
  DioService build() {
    final SharedPreferenceService sp = ref.watch(sharedPreferenceServiceProvider);
    final AliceService alice = ref.watch(aliceServiceProvider);
    return DioService(
      baseUrl: EnvConstants.baseUrl ?? '',
      accessToken: sp.getApiToken(),
      aliceService: alice,
    );
  }

  void update(DioService newService) => state = newService;
  DioService get current => state;
}

// ---------------------------------------------------------------------------
// CalculationMethod & Madhub — replace old StateProvider<String>
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
class CalculationMethod extends _$CalculationMethod {
  @override
  String build() => 'singapore';
  void set(String value) => state = value;
}

@Riverpod(keepAlive: true)
class Madhub extends _$Madhub {
  @override
  String build() => 'shafi';
  void set(String value) => state = value;
}

// ---------------------------------------------------------------------------
// Static service providers (plain Provider<T> — no state, no code gen needed)
// ---------------------------------------------------------------------------

final Provider<SharedPreferenceService> sharedPreferenceServiceProvider =
    Provider<SharedPreferenceService>((ref) => SharedPreferenceService());

final Provider<BookmarkApi> bookmarkApiProvider = Provider<BookmarkApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);
  return BookmarkApi(dioService.getDioWithAccessToken());
});

final Provider<CityApi> cityApiProvider = Provider<CityApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);
  return CityApi(dioService.getDioWithAccessToken());
});

final Provider<HabitApi> habitApiProvider = Provider<HabitApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);
  return HabitApi(dioService.getDioWithAccessToken());
});

final Provider<HabitGroupApi> habitGroupApiProvider =
    Provider<HabitGroupApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);
  return HabitGroupApi(dioService.getDioWithAccessToken());
});

final Provider<TadabburApi> tadabburApiProvider = Provider<TadabburApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);
  return TadabburApi(dioService.getDioWithStaticAPIKey());
});

final Provider<UserApi> userApiProvider = Provider<UserApi>((Ref ref) {
  final DioService dioService = ref.read(dioServiceProvider);
  return UserApi(dioService.getDio());
});

final Provider<AuthenticationService> authenticationService =
    Provider<AuthenticationService>((ref) {
  final UserApi userApi = ref.watch(userApiProvider);
  final SharedPreferenceService sharedPreferenceService =
      ref.watch(sharedPreferenceServiceProvider);
  final DioServiceNotifier dioNotifier =
      ref.read(dioServiceProvider.notifier);
  final AliceService aliceService = ref.watch(aliceServiceProvider);

  return AuthenticationService(
    userApi: userApi,
    sharedPreferenceService: sharedPreferenceService,
    onUpdateDioService: dioNotifier.update,
    getCurrentDioService: () => dioNotifier.current,
    aliceService: aliceService,
  );
});

final Provider<BookmarksService> bookmarksService =
    Provider<BookmarksService>((ref) {
  final BookmarkApi bookmarkApi = ref.watch(bookmarkApiProvider);
  return BookmarksService(bookmarkApi: bookmarkApi);
});

final Provider<HabitDailySummaryService> habitDailySummaryService =
    Provider<HabitDailySummaryService>((ref) {
  final SharedPreferenceService sharedPreferenceService =
      ref.watch(sharedPreferenceServiceProvider);
  final HabitApi habitApi = ref.watch(habitApiProvider);
  return HabitDailySummaryService(
    sharedPreferenceService: sharedPreferenceService,
    habitApi: habitApi,
  );
});

final Provider<FavoriteAyahsService> favoriteAyahsService =
    Provider<FavoriteAyahsService>((ref) => FavoriteAyahsService());

final Provider<MainPageProvider> mainPageProvider =
    Provider<MainPageProvider>((ref) => MainPageProvider());

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

final Provider<AliceService> aliceServiceProvider =
    Provider<AliceService>((ref) => AliceService(navigatorKey));

final Provider<RemoteConfigService> remoteConfigService =
    Provider<RemoteConfigService>((ref) => RemoteConfigService());

final Provider<PrayerTimesService> prayerTimesService =
    Provider<PrayerTimesService>((ref) {
  final NotificationService notificationService = NotificationService();
  final SharedPreferenceService sp = ref.watch(sharedPreferenceServiceProvider);
  return PrayerTimesService(
    notificationService: notificationService,
    sharedPreferenceService: sp,
  );
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
