import 'package:qurantafsir_flutter/shared/constants/icon.dart';

enum PrayerTimesList {
  fajr(icon: StoredIcon.iconFajrTime, label: 'Fajr'),
  dhuhr(icon: StoredIcon.iconDhuhrTime, label: 'Dzuhur'),
  ashr(icon: StoredIcon.iconAsrTime, label: 'Ashr'),
  magrib(icon: StoredIcon.iconMagribTime, label: 'Magrib'),
  isya(icon: StoredIcon.iconIsyaTime, label: 'Isya');

  const PrayerTimesList({
    required this.icon,
    required this.label,
  });

  final StoredIcon icon;
  final String label;
}
