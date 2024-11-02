import 'package:adhan/adhan.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times.dart';

class PrayerTimesService {
  PrayerTimesService({
    required this.notificationService,
    required this.sharedPreferenceService,
  });

  final NotificationService notificationService;
  final SharedPreferenceService sharedPreferenceService;

  late Coordinates? _coordinates;

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

  Future<void> setCoordinates(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    await sharedPreferenceService.setLocation(latitude, longitude);
    await sharedPreferenceService.setCityName(cityName);
    _coordinates = Coordinates(latitude, longitude);
  }

  PrayerTimes? getTodayPrayerTimes() {
    if (_coordinates == null) {
      return null;
    }
    final CalculationParameters params =
        CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    return PrayerTimes.today(_coordinates!, params);
  }

  Future<void> setupPrayerTimesReminder() async {
    final PrayerTimes? prayerTimes = getTodayPrayerTimes();
    if (prayerTimes == null) {
      return;
    }

    final List<DateTime> prayerTimeList = <DateTime>[
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    for (int i = 0; i < prayerTimeList.length; i++) {
      scheduleQuranReadingReminder(
        prayerTime: prayerTimeList[i],
        id: i,
      );

      final String time =
          '${formatTwoDigits(prayerTimeList[i].hour)}:${formatTwoDigits(prayerTimeList[i].minute)}';
      await notificationService.zonedSchedule(
        id: i,
        title: '${prayerTimeEnums[i].label} prayer time is coming - $time',
        body: prayerTimeEnums[i].notifLabel,
        scheduledDateTime: prayerTimeList[i],
      );
    }
  }
}
