class PrayerModel {
  final int index;
  final String image;
  final String prayerNames;
  final DateTime prayerTime;
  final bool alarm;

  PrayerModel(
      {required this.index,
      required this.image,
      required this.prayerNames,
      required this.prayerTime,
      required this.alarm});
}
