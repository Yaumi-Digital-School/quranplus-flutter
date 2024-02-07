class AppConstants {
  static String baseUrl = 'http://104.198.39.246:8080';
  static const String jsonSurat = 'data/quran.json';
  static const String jsonJuz = 'data/juz.json';
  static const String ayahPageJson = 'data/verse-to-page.json';
  static const String appName = 'Quran Tafsir';

  static const String initPrayerTimesNotifKey =
      'initialize-prayer-times-notifications';
}

enum SignInType {
  google,
  apple,
}

enum AppUpdateType {
  forceUpdate,
  optionalUpdate,
}
