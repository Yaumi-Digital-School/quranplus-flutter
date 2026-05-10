import 'package:adhan_dart/adhan_dart.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times.dart';

const reminderNotifNormalizer = 100;
const quranReminderDays = 7;
const prayersPerDay = 5;

class PrayerTimesService {
  PrayerTimesService({
    required this.notificationService,
    required this.sharedPreferenceService,
  });

  final NotificationService notificationService;
  final SharedPreferenceService sharedPreferenceService;

  Coordinates? _coordinates;

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
      date: (date ?? DateTime.now()).toUtc(),
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
