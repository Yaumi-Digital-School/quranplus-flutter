import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times.dart';

const reminderNotifNormalizer = 100;
const quranReminderDays = 7;
const prayersPerDay = 5;

/// Anchors a local date at noon before converting to UTC, so the UTC calendar
/// day used by adhan_dart always matches the intended LOCAL calendar day.
///
/// The naive `local.toUtc()` breaks in positive-offset zones (e.g. UTC+7):
/// between local midnight and ~07:00 the UTC instant falls on the PREVIOUS
/// calendar day, so prayer times get computed for the wrong day (everything
/// reads as "already passed"). Anchoring at 12:00 local keeps the UTC day
/// stable for all realistic timezones. Pure — the unit-test seam for Bug A.
DateTime anchorDateForPrayerCalc(DateTime local) {
  return DateTime(local.year, local.month, local.day, 12).toUtc();
}

/// Builds the title for the ongoing "today's prayer times" notification.
/// Appends " · <city>" only when a non-empty city name is available.
/// Pure and side-effect free — the unit-test seam for the notification content.
String buildPersistentPrayerTimesTitle({
  String? cityName,
  required DateTime date,
}) {
  const String base = 'Prayer Times Today';
  if (cityName == null || cityName.isEmpty) {
    return base;
  }

  return '$base · $cityName';
}

/// Builds the multi-line body for the ongoing "today's prayer times"
/// notification: one line per prayer as '<label>  <HH:mm>', in the canonical
/// order (fajr, dhuhr, asr, maghrib, isha) using the device-local times.
/// Pure and side-effect free — the unit-test seam for the notification content.
String buildPersistentPrayerTimesBody(PrayerTimes prayerTimes) {
  final List<DateTime> prayerTimeList = <DateTime>[
    prayerTimes.fajr,
    prayerTimes.dhuhr,
    prayerTimes.asr,
    prayerTimes.maghrib,
    prayerTimes.isha,
  ];

  final List<String> lines = <String>[];
  for (int i = 0; i < prayerTimeList.length; i++) {
    final DateTime localTime = prayerTimeList[i].toLocal();
    final String time =
        '${formatTwoDigits(localTime.hour)}:${formatTwoDigits(localTime.minute)}';
    lines.add('${prayerTimeEnums[i].label}  $time');
  }

  return lines.join('\n');
}

class PrayerTimesService {
  PrayerTimesService({
    required this.notificationService,
    required this.sharedPreferenceService,
  });

  final NotificationService notificationService;
  final SharedPreferenceService sharedPreferenceService;

  Coordinates? _coordinates;

  /// Overrides the `Platform.isAndroid` guard in tests (the test host reports
  /// non-Android). Never set in production.
  @visibleForTesting
  bool? debugIsAndroidOverride;

  bool get _isAndroid => debugIsAndroidOverride ?? Platform.isAndroid;

  void init() {
    final location = sharedPreferenceService.getLocation();
    if (location.length > 1 && location[0] != null && location[1] != null) {
      _coordinates = Coordinates(location[0]!, location[1]!);
    } else {
      _coordinates = null;
    }
  }

  String? getCityName() {
    return sharedPreferenceService.getCityName();
  }

  bool getAutoDetectLocation() {
    return sharedPreferenceService.getAutoDetectLocation();
  }

  Future<void> setAutoDetectLocation(bool value) {
    return sharedPreferenceService.setAutoDetectLocation(value);
  }

  Future<void> setCoordinates(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    await sharedPreferenceService.setLocation(latitude, longitude);
    await sharedPreferenceService.setCityName(cityName);
    _coordinates = Coordinates(latitude, longitude);
  }

  PrayerTimes? getPrayerTimesByDate({
    DateTime? date,
    String calculationMethod = 'singapore',
    String madhab = 'shafi',
  }) {
    if (_coordinates == null) {
      return null;
    }

    final CalculationParameters params = _getCalculationParameters(
      calculationMethod,
      madhab,
    );

    return PrayerTimes(
      coordinates: _coordinates!,
      date: anchorDateForPrayerCalc(date ?? DateTime.now()),
      calculationParameters: params,
    );
  }

  CalculationParameters _getCalculationParameters(
    String method,
    String madhab,
  ) {
    late CalculationParameters params;

    switch (method.toLowerCase()) {
      case 'singapore':
        params = CalculationMethodParameters.singapore();
        break;
      case 'muslimworldleague':
        params = CalculationMethodParameters.muslimWorldLeague();
        break;
      case 'egyptian':
        params = CalculationMethodParameters.egyptian();
        break;
      case 'ummAlqura':
        params = CalculationMethodParameters.ummAlQura();
        break;
      default:
        params = CalculationMethodParameters.singapore();
    }

    params.madhab = madhab.toLowerCase() == 'hanafi'
        ? Madhab.hanafi
        : Madhab.shafi;

    return params;
  }

  Future<void> setupPrayerTimesReminder({
    String calculationMethod = 'singapore',
    String madhab = 'shafi',
    Map<PrayerTimesList, bool>? adhanEnabled,
  }) async {
    final PrayerTimes? prayerTimes = getPrayerTimesByDate(
      calculationMethod: calculationMethod,
      madhab: madhab,
    );
    if (prayerTimes == null) {
      return;
    }

    await notificationService.cancelAllNotifications();

    final List<DateTime> prayerTimeList = <DateTime>[
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    final DateTime now = DateTime.now();

    for (int i = 0; i < prayerTimeList.length; i++) {
      final PrayerTimesList prayer = prayerTimeEnums[i];
      final bool enabled = adhanEnabled?[prayer] ?? true;
      final DateTime localTime = prayerTimeList[i].toLocal();

      if (!localTime.isAfter(now)) continue;

      if (enabled) {
        try {
          scheduleQuranReadingReminder(
            prayerTime: localTime,
            id: i + reminderNotifNormalizer,
          );
        } catch (_) {}

        try {
          final String time =
              '${formatTwoDigits(localTime.hour)}:${formatTwoDigits(localTime.minute)}';
          await notificationService.zonedSchedule(
            id: i,
            title: '${prayer.label} prayer time is coming - $time',
            body: prayer.notifLabel,
            scheduledDateTime: localTime,
          );
        } catch (_) {}
      }
    }

    // Repost the ongoing "today's prayer times" notification last: the
    // `cancelAllNotifications()` above wiped everything, so this must run after
    // it. This single hook makes every refresh path (launch worker, daily
    // periodic worker, adhan toggle, location change) restore the notification.
    await showPersistentPrayerTimesNotification();
  }

  /// Posts (or refreshes) the ongoing, non-dismissable notification listing all
  /// of today's prayer times. Android-only; a no-op when the feature toggle is
  /// off or no location has been set.
  Future<void> showPersistentPrayerTimesNotification() async {
    if (!_isAndroid) return;
    if (!sharedPreferenceService.getPersistentPrayerNotifEnabled()) return;

    final PrayerTimes? prayerTimes = getPrayerTimesByDate();
    if (prayerTimes == null) return;

    final String title = buildPersistentPrayerTimesTitle(
      cityName: getCityName(),
      date: DateTime.now(),
    );
    final String body = buildPersistentPrayerTimesBody(prayerTimes);

    await notificationService.showOngoing(
      id: persistentPrayerTimesNotifId,
      title: title,
      body: body,
    );
  }

  /// Removes the ongoing "today's prayer times" notification (used when the
  /// settings toggle is turned off).
  Future<void> cancelPersistentPrayerTimesNotification() async {
    await notificationService.cancel(persistentPrayerTimesNotifId);
  }

  /// Schedules prayer time notifications for multiple days ahead.
  /// Used on iOS where background tasks are unreliable.
  /// Prayer: 7 days × 5 = 35 notifications (IDs 0–34)
  /// Quran reminders: 5 days × 5 = 25 notifications (IDs 100–124)
  /// Total: 60, stays under iOS's 64-notification limit.
  Future<void> setupMultiDayPrayerTimesReminder({
    int days = 7,
    String calculationMethod = 'singapore',
    String madhab = 'shafi',
    Map<PrayerTimesList, bool>? adhanEnabled,
  }) async {
    await notificationService.cancelAllNotifications();

    final DateTime now = DateTime.now();

    for (int dayOffset = 0; dayOffset < days; dayOffset++) {
      final DateTime targetDate = now.add(Duration(days: dayOffset));
      final PrayerTimes? prayerTimes = getPrayerTimesByDate(
        date: targetDate,
        calculationMethod: calculationMethod,
        madhab: madhab,
      );

      if (prayerTimes == null) return;

      final List<DateTime> prayerTimeList = <DateTime>[
        prayerTimes.fajr,
        prayerTimes.dhuhr,
        prayerTimes.asr,
        prayerTimes.maghrib,
        prayerTimes.isha,
      ];

      for (int i = 0; i < prayerTimeList.length; i++) {
        final PrayerTimesList prayer = prayerTimeEnums[i];
        final bool enabled = adhanEnabled?[prayer] ?? true;
        final DateTime localTime = prayerTimeList[i].toLocal();

        if (!localTime.isAfter(now) || !enabled) continue;

        try {
          final String time =
              '${formatTwoDigits(localTime.hour)}:${formatTwoDigits(localTime.minute)}';
          final int notificationId = dayOffset * 5 + i;

          await notificationService.zonedSchedule(
            id: notificationId,
            title: '${prayer.label} prayer time is coming - $time',
            body: prayer.notifLabel,
            scheduledDateTime: localTime,
          );
        } catch (_) {}
      }
    }

    await setupMultiDayQuranReminders(
      calculationMethod: calculationMethod,
      madhab: madhab,
      adhanEnabled: adhanEnabled,
    );
  }

  Future<void> setupMultiDayQuranReminders({
    int days = 7,
    String calculationMethod = 'singapore',
    String madhab = 'shafi',
    Map<PrayerTimesList, bool>? adhanEnabled,
  }) async {
    final DateTime now = DateTime.now();

    for (int dayOffset = 0; dayOffset < days; dayOffset++) {
      final DateTime targetDate = now.add(Duration(days: dayOffset));
      final PrayerTimes? prayerTimes = getPrayerTimesByDate(
        date: targetDate,
        calculationMethod: calculationMethod,
        madhab: madhab,
      );

      if (prayerTimes == null) return;

      final List<DateTime> prayerTimeList = <DateTime>[
        prayerTimes.fajr,
        prayerTimes.dhuhr,
        prayerTimes.asr,
        prayerTimes.maghrib,
        prayerTimes.isha,
      ];

      for (int i = 0; i < prayerTimeList.length; i++) {
        final PrayerTimesList prayer = prayerTimeEnums[i];
        final bool enabled = adhanEnabled?[prayer] ?? true;
        final DateTime reminderTime = prayerTimeList[i].toLocal().add(
          const Duration(minutes: 30),
        );

        if (!reminderTime.isAfter(now) || !enabled) continue;

        try {
          await notificationService.zonedSchedule(
            id: reminderNotifNormalizer + dayOffset * 5 + i,
            title: "Don't miss your Quran reading goal",
            body:
                "Your Quran reading goal is within reach. Take a moment today to reflect on the wisdom of the Quran.",
            scheduledDateTime: reminderTime,
          );
        } catch (_) {}
      }
    }
  }
}
