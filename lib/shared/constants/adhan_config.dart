import 'package:adhan/adhan.dart';

const List<String> prayerNames = [
  '-',
  'Fajr',
  'Sunrise',
  'Dhuhr',
  'Asr',
  'Maghrib',
  'Isha'
];

Map<CalculationMethod, String> methodTitles = {
  CalculationMethod.muslim_world_league: 'Muslim World League',
  CalculationMethod.egyptian: 'Egyptian',
  CalculationMethod.karachi: 'Karachi',
  CalculationMethod.umm_al_qura: 'Umm Al-Qura',
  CalculationMethod.dubai: 'Dubai',
  CalculationMethod.qatar: 'Qatar',
  CalculationMethod.kuwait: 'Kuwait',
  CalculationMethod.moon_sighting_committee: 'Moonsighting Committee',
  CalculationMethod.singapore: 'Singapore',
  CalculationMethod.north_america: 'North America',
  CalculationMethod.turkey: 'Turkey',
  CalculationMethod.tehran: 'Tehran',
  CalculationMethod.other: 'Other'
};

Map<Madhab, String> madhabTitles = {
  Madhab.hanafi: 'Hanafi',
  Madhab.shafi: 'Shafi'
};