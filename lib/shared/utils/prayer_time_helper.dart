import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

Duration getPrayerTimeDiff(DateTime _time) {
  return DateTime.now().difference(_time);
}

DateTime getPrayerTime(PrayerTimes _prayerTimes, Prayer _prayer) {
  switch (_prayer) {
    case Prayer.fajr:
      return _prayerTimes.fajr;
    case Prayer.sunrise:
      return _prayerTimes.sunrise;
    case Prayer.dhuhr:
      return _prayerTimes.dhuhr;
    case Prayer.asr:
      return _prayerTimes.asr;
    case Prayer.maghrib:
      return _prayerTimes.maghrib;
    case Prayer.isha:
      return _prayerTimes.isha;
    default:
      return DateTime.now();
  }
}

Future<CalculationParameters> getPrayerParams() async {
  CalculationParameters prayerParams;
  final savedParams = await getSavedPrayerParams();
  prayerParams = CalculationMethod.values[savedParams['prayerMethodIndex']!]
      .getParameters();
  prayerParams.madhab = Madhab.values[savedParams['prayerMadhabIndex']!];

  return prayerParams;
}

Future<Map<String, int?>> getSavedPrayerParams() async {
  int? methodIndex = 0;
  int? madhabIndex = 0;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('prayerMethodIndex') &&
      prefs.containsKey('prayerMadhabIndex')) {
    methodIndex = prefs.getInt('prayerMethodIndex');
    madhabIndex = prefs.getInt('prayerMadhabIndex');
  }

  return {'prayerMethodIndex': methodIndex, 'prayerMadhabIndex': madhabIndex};
}

Future<void> savePrayerParams(int methodIndex, int madhabIndex) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('prayerMethodIndex', methodIndex);
  await prefs.setInt('prayerMadhabIndex', madhabIndex);
}
