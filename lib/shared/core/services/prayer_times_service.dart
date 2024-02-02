import 'package:adhan/adhan.dart';

class PrayerTimesService {
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
}
