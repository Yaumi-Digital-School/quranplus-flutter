import 'package:adhan/adhan.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times.dart';

const List<PrayerTimesList> prayerTimeEnums = <PrayerTimesList>[
  PrayerTimesList.fajr,
  PrayerTimesList.dhuhr,
  PrayerTimesList.ashr,
  PrayerTimesList.magrib,
  PrayerTimesList.isya,
];

const Map<PrayerTimesList, String> prayerTimeReminderMessages =
    <PrayerTimesList, String>{
  PrayerTimesList.fajr: 'Start your day with a peaceful prayer',
  PrayerTimesList.dhuhr: 'Take a few moments to pause from your busy day',
  PrayerTimesList.ashr: "Let's recharge your energy",
  PrayerTimesList.magrib: 'Take a moment to reflect and pray',
  PrayerTimesList.isya: 'Wind down your day with a moment of spirituality',
};

class PrayerTimesService {
  PrayerTimesService({
    required this.notificationService,
  });

  final NotificationService notificationService;

  late Coordinates _coordinates;

  void init() {
    // Depok
    _coordinates = Coordinates(-6.4025, 106.7942);
  }

  void setCoordinates(double latitude, double longitude) {
    _coordinates = Coordinates(latitude, longitude);
  }

  PrayerTimes getTodayPrayerTimes() {
    final CalculationParameters params =
        CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    return PrayerTimes.today(_coordinates, params);
  }

  Future<void> setupPrayerTimesReminder() async {
    final PrayerTimes prayerTimes = getTodayPrayerTimes();
    final List<DateTime> prayerTimeList = <DateTime>[
      prayerTimes.fajr,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha,
    ];

    for (int i = 0; i < prayerTimeList.length; i++) {
      final String time =
          '${formatTwoDigits(prayerTimeList[i].hour)}:${formatTwoDigits(prayerTimeList[i].minute)}';
      await notificationService.zonedSchedule(
        id: i,
        title: '${prayerTimeEnums[i].label} prayer time is coming - $time',
        body: prayerTimeReminderMessages[prayerTimeEnums[i]] ?? '',
        scheduledDateTime: prayerTimeList[i],
      );

      scheduleQuranReadingReminder(
        prayerTime: prayerTimeList[i],
        id: i,
      );
    }
  }
}
