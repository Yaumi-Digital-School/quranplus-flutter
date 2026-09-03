// Tests for the persistent "today's prayer times" notification.
//
// The pure content builders (buildPersistentPrayerTimesTitle /
// buildPersistentPrayerTimesBody) are the unit-test seam: they take a real
// adhan_dart PrayerTimes and produce deterministic title/body strings with no
// platform side effects. The service-level tests exercise the guard logic and
// notification-service wiring through a recording fake NotificationService.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recording fake so we can assert which NotificationService methods the
/// service calls, without touching the real flutter_local_notifications plugin.
class _RecordingNotificationService extends NotificationService {
  _RecordingNotificationService() : super.forTesting();

  final List<int> shownOngoingIds = <int>[];
  final List<int> canceledIds = <int>[];
  int cancelAllCount = 0;

  @override
  Future<void> showOngoing({
    required int id,
    required String title,
    required String body,
  }) async {
    shownOngoingIds.add(id);
  }

  @override
  Future<void> cancel(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCount++;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {}
}

PrayerTimes buildJakartaPrayerTimes() {
  // Fixed Jakarta coordinates and a fixed UTC date, mirroring how
  // getPrayerTimesByDate constructs PrayerTimes (date passed as .toUtc()).
  final CalculationParameters params = CalculationMethodParameters.singapore();
  params.madhab = Madhab.shafi;

  return PrayerTimes(
    coordinates: const Coordinates(-6.2, 106.8),
    date: DateTime.utc(2026, 9, 3),
    calculationParameters: params,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildPersistentPrayerTimesBody', () {
    test('produces exactly 5 lines, each ending in HH:mm', () {
      final String body = buildPersistentPrayerTimesBody(
        buildJakartaPrayerTimes(),
      );
      final List<String> lines = body.split('\n');

      expect(lines.length, 5);
      final RegExp timeSuffix = RegExp(r'\d{2}:\d{2}$');
      for (final String line in lines) {
        expect(timeSuffix.hasMatch(line), isTrue, reason: 'bad line: "$line"');
      }
    });

    test('contains every prayer label in canonical order', () {
      final String body = buildPersistentPrayerTimesBody(
        buildJakartaPrayerTimes(),
      );
      final List<String> lines = body.split('\n');

      expect(lines[0], startsWith('Fajr'));
      expect(lines[1], startsWith('Dzuhur'));
      expect(lines[2], startsWith('Ashr'));
      expect(lines[3], startsWith('Magrib'));
      expect(lines[4], startsWith('Isya'));

      for (final String label in <String>[
        'Fajr',
        'Dzuhur',
        'Ashr',
        'Magrib',
        'Isya',
      ]) {
        expect(body, contains(label));
      }
    });
  });

  group('buildPersistentPrayerTimesTitle', () {
    final DateTime date = DateTime(2026, 9, 3);

    test('includes the city and separator when a city is provided', () {
      final String title = buildPersistentPrayerTimesTitle(
        cityName: 'Jakarta',
        date: date,
      );

      expect(title, contains('Jakarta'));
      expect(title, contains('·'));
    });

    test('omits the separator when city is null', () {
      final String title = buildPersistentPrayerTimesTitle(
        cityName: null,
        date: date,
      );

      expect(title, isNot(contains('·')));
      expect(title, 'Prayer Times Today');
    });

    test('omits the separator when city is empty', () {
      final String title = buildPersistentPrayerTimesTitle(
        cityName: '',
        date: date,
      );

      expect(title, isNot(contains('·')));
    });
  });

  group('PrayerTimesService persistent notification', () {
    Future<SharedPreferenceService> makeSharedPreferences(
      Map<String, Object> values,
    ) async {
      SharedPreferences.setMockInitialValues(values);
      final SharedPreferenceService sp = SharedPreferenceService();
      await sp.init();
      return sp;
    }

    test('cancelPersistentPrayerTimesNotification cancels ID 900', () async {
      final SharedPreferenceService sp = await makeSharedPreferences(
        <String, Object>{},
      );
      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );

      await service.cancelPersistentPrayerTimesNotification();

      expect(fake.canceledIds, contains(persistentPrayerTimesNotifId));
    });

    test(
      'posts an ongoing ID 900 when enabled and a location is set',
      () async {
        final SharedPreferenceService sp = await makeSharedPreferences(
          <String, Object>{},
        );
        await sp.setLocation(-6.2, 106.8);
        await sp.setCityName('Jakarta');
        await sp.setPersistentPrayerNotifEnabled(true);

        final _RecordingNotificationService fake =
            _RecordingNotificationService();
        final PrayerTimesService service = PrayerTimesService(
          notificationService: fake,
          sharedPreferenceService: sp,
        );
        service.init();
        service.debugIsAndroidOverride = true;

        await service.showPersistentPrayerTimesNotification();

        expect(fake.shownOngoingIds, <int>[persistentPrayerTimesNotifId]);
      },
    );

    test('is a no-op when the toggle is disabled', () async {
      final SharedPreferenceService sp = await makeSharedPreferences(
        <String, Object>{},
      );
      await sp.setLocation(-6.2, 106.8);
      await sp.setPersistentPrayerNotifEnabled(false);

      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );
      service.init();
      service.debugIsAndroidOverride = true;

      await service.showPersistentPrayerTimesNotification();

      expect(fake.shownOngoingIds, isEmpty);
    });

    test('is a no-op when no location is set', () async {
      final SharedPreferenceService sp = await makeSharedPreferences(
        <String, Object>{},
      );
      await sp.setPersistentPrayerNotifEnabled(true);

      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );
      service.init();
      service.debugIsAndroidOverride = true;

      await service.showPersistentPrayerTimesNotification();

      expect(fake.shownOngoingIds, isEmpty);
    });

    test('is a no-op on non-Android platforms', () async {
      final SharedPreferenceService sp = await makeSharedPreferences(
        <String, Object>{},
      );
      await sp.setLocation(-6.2, 106.8);
      await sp.setPersistentPrayerNotifEnabled(true);

      final _RecordingNotificationService fake =
          _RecordingNotificationService();
      final PrayerTimesService service = PrayerTimesService(
        notificationService: fake,
        sharedPreferenceService: sp,
      );
      service.init();
      service.debugIsAndroidOverride = false;

      await service.showPersistentPrayerTimesNotification();

      expect(fake.shownOngoingIds, isEmpty);
    });
  });
}
