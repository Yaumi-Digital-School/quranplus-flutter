import 'package:qurantafsir_flutter/shared/constants/icon.dart';

enum PrayerTimesList {
  fajr(
    icon: StoredIcon.iconFajrTime,
    label: 'Fajr',
    notifLabel: 'Start your day with a peaceful prayer',
  ),
  dhuhr(
    icon: StoredIcon.iconDhuhrTime,
    label: 'Dzuhur',
    notifLabel: 'Take a few moments to pause from your busy day',
  ),
  ashr(
    icon: StoredIcon.iconAsrTime,
    label: 'Ashr',
    notifLabel: "Let's recharge your energy",
  ),
  magrib(
    icon: StoredIcon.iconMagribTime,
    label: 'Magrib',
    notifLabel: 'Take a moment to reflect and pray',
  ),
  isya(
    icon: StoredIcon.iconIsyaTime,
    label: 'Isya',
    notifLabel: 'Wind down your day with a moment of spirituality',
  );

  const PrayerTimesList({
    required this.icon,
    required this.label,
    required this.notifLabel,
  });

  final StoredIcon icon;
  final String label;
  final String notifLabel;
}

const List<PrayerTimesList> prayerTimeEnums = <PrayerTimesList>[
  PrayerTimesList.fajr,
  PrayerTimesList.dhuhr,
  PrayerTimesList.ashr,
  PrayerTimesList.magrib,
  PrayerTimesList.isya,
];

enum PrayerTimesWorker {
  prayerTimeReminder(
    name: 'initializePrayerTimesNotifications',
    tag: 'prayerTimesReminder',
  ),
  quranTimeReminder(
    name: 'readingReminder',
    tag: 'quranTimeReminder',
  );

  const PrayerTimesWorker({
    required this.name,
    required this.tag,
  });

  final String name;
  final String tag;
}
