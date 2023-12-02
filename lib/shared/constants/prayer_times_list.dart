import 'package:qurantafsir_flutter/shared/constants/icon.dart';

class PrayerTimesList {
  PrayerTimesList();

  static List<String> listPrayerTimes = [
    "Fajr",
    "Dzuhur",
    "Ashr",
    "Magrib",
    "Isya",
  ];
  static List<String> listIconPrayerTimes = [
    IconPath.iconFajrTime,
    IconPath.iconDhuhrTime,
    IconPath.iconAsrTime,
    IconPath.iconMagribTime,
    IconPath.iconIsyaTime,
  ];
}
