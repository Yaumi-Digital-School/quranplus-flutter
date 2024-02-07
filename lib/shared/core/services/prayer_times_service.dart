import 'package:adhan/adhan.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times_list.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';

const List<PrayerTimesList> prayerTimeEnums = <PrayerTimesList>[
  PrayerTimesList.fajr,
  PrayerTimesList.dhuhr,
  PrayerTimesList.ashr,
  PrayerTimesList.magrib,
  PrayerTimesList.isya,
];

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
        title: 'Quran Plus',
        body: '${prayerTimeEnums[i].label} prayer time is coming - $time',
        scheduledDateTime: prayerTimeList[i],
      );
    }
  }
}
