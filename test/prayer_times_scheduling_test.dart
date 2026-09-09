// Tests for the prayer-notification scheduling pipeline.
//
// Covers four regressions in the adzan + Quran-reminder scheduling flow:
//   1. SharedPreferenceService.init() must never throw when the platform
//      keystore misbehaves in a background isolate — otherwise the Workmanager
//      worker that schedules adzan + Quran reminders dies for the whole day.
//   2. The daily worker / iOS resync paths call the setup methods with
//      adhanEnabled == null; they must honor the user's saved per-prayer toggles
//      instead of resurrecting adzan the user disabled.
//   3. The settings notifier must default toggles to all-on and must NOT persist
//      that derived default (which used to lock in an all-off map forever).
//   4. iOS multi-day scheduling must stay within the 64-pending limit (Quran
//      reminders capped at 5 days → IDs 100..124).
//
// The service-level assertions use a recording fake NotificationService
// (mirroring prayer_times_persistent_notification_test.dart). Because the
// service reads DateTime.now() with no seam, the day-0 window is time-of-day
// dependent, so assertions are structural (by prayer index modulo 5 across the
// multi-day window) rather than exact times/counts.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/notification_settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recording fake so we can assert which notifications the service scheduled,
/// without touching the real flutter_local_notifications plugin.
class _RecordingNotificationService extends NotificationService {
  _RecordingNotificationService() : super.forTesting();

  final List<int> zonedScheduledIds = <int>[];
  int cancelAllCount = 0;

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    zonedScheduledIds.add(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCount++;
  }

  @override
  Future<void> showOngoing({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

/// Secure storage that throws on every access, mimicking a background-isolate
/// keystore failure. `Fake`'s noSuchMethod throws UnimplementedError, so any
/// call init() makes (read/write) fails.
class _ThrowingSecureStorage extends Fake implements FlutterSecureStorage {}

Future<SharedPreferenceService> makeLocatedSharedPreferences({
  Map<String, Object> values = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(values);
  // init() reads the auth token from secure storage; back it with an in-memory
  // platform so the plugin channel isn't hit in tests.
  FlutterSecureStorage.setMockInitialValues(<String, String>{});
  final SharedPreferenceService sp = SharedPreferenceService();
  await sp.init();
  await sp.setLocation(-6.2, 106.8);
  await sp.setCityName('Jakarta');
  return sp;
}

Map<PrayerTimesList, bool> allEnabledExcept(PrayerTimesList disabled) {
  return <PrayerTimesList, bool>{
    for (final PrayerTimesList p in PrayerTimesList.values) p: p != disabled,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferenceService.init with a failing keystore (Bug 1)', () {
    test('completes and falls back to the legacy plaintext token', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'api-token': 'legacy-plain-token',
        'cityName': 'Jakarta',
      });
      final SharedPreferenceService sp = SharedPreferenceService(
        secureStorage: _ThrowingSecureStorage(),
      );

      // Must not throw even though every secure-storage call fails.
      await sp.init();

      expect(sp.getApiToken(), 'legacy-plain-token');
      // Other (non-secure) prefs remain readable.
      expect(sp.getCityName(), 'Jakarta');
    });

    test('completes with an empty token when no legacy token exists', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferenceService sp = SharedPreferenceService(
        secureStorage: _ThrowingSecureStorage(),
      );

      await sp.init();

      expect(sp.getApiToken(), '');
    });
  });

  group('setupMultiDayPrayerTimesReminder honors saved toggles (Bug 2)', () {
    test('skips a disabled prayer every day but keeps enabled ones', () async {
      final SharedPreferenceService sp = await makeLocatedSharedPreferences();
      // Persist the user's choice: everything on except Isya (index 4).
      await sp.setAdhanEnabledMap(allEnabledExcept(PrayerTimesList.isya));

      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );
      service.init();
      service.debugIsAndroidOverride = false;

      // No adhanEnabled arg → must load the saved map.
      await service.setupMultiDayPrayerTimesReminder();

      final List<int> prayerIds = fake.zonedScheduledIds
          .where((int id) => id < reminderNotifNormalizer)
          .toList();

      // Isya is index 4 → its notification ids satisfy id % 5 == 4; none should
      // be scheduled. Fajr is index 0 → future days guarantee at least one.
      expect(prayerIds.where((int id) => id % 5 == 4), isEmpty);
      expect(prayerIds.where((int id) => id % 5 == 0), isNotEmpty);
    });
  });

  group('setupPrayerTimesReminder honors saved toggles (Bug 2)', () {
    test('schedules no adzan when the saved map is all-off', () async {
      final SharedPreferenceService sp = await makeLocatedSharedPreferences();
      await sp.setAdhanEnabledMap(<PrayerTimesList, bool>{
        for (final PrayerTimesList p in PrayerTimesList.values) p: false,
      });

      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );
      service.init();
      service.debugIsAndroidOverride = true;

      // No adhanEnabled arg → loads the all-off map; nothing gets scheduled.
      await service.setupPrayerTimesReminder();

      expect(
        fake.zonedScheduledIds.where((int id) => id < reminderNotifNormalizer),
        isEmpty,
      );
      expect(fake.cancelAllCount, 1);
    });
  });

  group('setupMultiDayPrayerTimesReminder stays within the limit (Bug 4)', () {
    test('caps Quran reminders at ids 100..124 and total ≤ 60', () async {
      // No saved map + a location → every prayer defaults on (worst case).
      final SharedPreferenceService sp = await makeLocatedSharedPreferences();

      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );
      service.init();
      service.debugIsAndroidOverride = false;

      await service.setupMultiDayPrayerTimesReminder();

      final List<int> quranIds = fake.zonedScheduledIds
          .where((int id) => id >= reminderNotifNormalizer)
          .toList();

      // 5 days × 5 prayers → ids 100..124, never 125+ (7-day default would).
      expect(quranIds, isNotEmpty);
      expect(
        quranIds.every((int id) => id >= 100 && id <= 124),
        isTrue,
        reason: 'quran reminder ids out of budget: $quranIds',
      );
      // 35 prayer + 25 quran = 60 pending max, under iOS's 64 limit.
      expect(fake.zonedScheduledIds.length, lessThanOrEqualTo(60));
    });
  });

  group(
    'SharedPreferenceService heals an auto-persisted all-off adhan map '
    '(build 107 regression)',
    () {
      // The stored map is a JSON object of {enumName: bool}; see
      // SharedPreferenceService.setAdhanEnabledMap for the exact encoding.
      final String allFalseJson = json.encode(<String, bool>{
        for (final PrayerTimesList p in PrayerTimesList.values) p.name: false,
      });
      final Map<PrayerTimesList, bool> allFalseMap = <PrayerTimesList, bool>{
        for (final PrayerTimesList p in PrayerTimesList.values) p: false,
      };

      test(
        'drops a stored all-false map and sets the migration flag when unset',
        () async {
          // Simulate build 107's bug: opening notification settings before a
          // location existed auto-persisted an all-false map, and this
          // device has never run the heal.
          SharedPreferences.setMockInitialValues(<String, Object>{
            'adhan-enabled-map': allFalseJson,
          });
          FlutterSecureStorage.setMockInitialValues(<String, String>{});

          final SharedPreferenceService sp = SharedPreferenceService();
          await sp.init();

          expect(sp.getAdhanEnabledMap(), isNull);

          final SharedPreferences rawPrefs = await SharedPreferences.getInstance();
          expect(rawPrefs.getBool('adhan-all-off-migration-done'), isTrue);
        },
      );

      test(
        'preserves a stored mixed map unchanged and still sets the migration flag',
        () async {
          final String mixedJson = json.encode(<String, bool>{
            for (final PrayerTimesList p in PrayerTimesList.values)
              p.name: p != PrayerTimesList.isya,
          });
          SharedPreferences.setMockInitialValues(<String, Object>{
            'adhan-enabled-map': mixedJson,
          });
          FlutterSecureStorage.setMockInitialValues(<String, String>{});

          final SharedPreferenceService sp = SharedPreferenceService();
          await sp.init();

          expect(
            sp.getAdhanEnabledMap(),
            allEnabledExcept(PrayerTimesList.isya),
          );

          final SharedPreferences rawPrefs = await SharedPreferences.getInstance();
          expect(rawPrefs.getBool('adhan-all-off-migration-done'), isTrue);
        },
      );

      test(
        'preserves a stored all-false map when the migration flag is already set',
        () async {
          // The heal already ran once on this device (flag persisted); a
          // later all-false map reflects a deliberate user choice and must
          // survive future init() calls.
          SharedPreferences.setMockInitialValues(<String, Object>{
            'adhan-enabled-map': allFalseJson,
            'adhan-all-off-migration-done': true,
          });
          FlutterSecureStorage.setMockInitialValues(<String, String>{});

          final SharedPreferenceService sp = SharedPreferenceService();
          await sp.init();

          expect(sp.getAdhanEnabledMap(), allFalseMap);
        },
      );
    },
  );

  group('NotificationSettingsPageNotifier default (Bug 3)', () {
    test('defaults all prayers on and does not persist the default', () async {
      // No saved adhan map, no location.
      SharedPreferences.setMockInitialValues(<String, Object>{});
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final SharedPreferenceService sp = SharedPreferenceService();
      await sp.init();

      final ProviderContainer container = ProviderContainer(
        overrides: [sharedPreferenceServiceProvider.overrideWithValue(sp)],
      );
      addTearDown(container.dispose);

      final NotificationSettingsPageState state = container.read(
        notificationSettingsPageProvider,
      );

      for (final PrayerTimesList p in PrayerTimesList.values) {
        expect(
          state.adhanEnabled[p],
          isTrue,
          reason: 'prayer $p should default on',
        );
      }

      // build() must not write the derived default back to prefs.
      expect(sp.getAdhanEnabledMap(), isNull);
    });
  });
}
