import 'dart:convert';

import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  late SharedPreferences _sharedPreferences;

  final String _readingSettingsKey = 'reading-settings';

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setReadingSettings(ReadingSettings readingSettings) {
    Map<String, dynamic> toJsonValue = readingSettings.toJson();

    _sharedPreferences.setString(_readingSettingsKey, json.encode(toJsonValue));
  }

  ReadingSettings getReadingSettings() {
    dynamic result = _sharedPreferences.get(_readingSettingsKey);
    if (result == null) {
      return ReadingSettings();
    }

    ReadingSettings resultInObject = ReadingSettings.fromJson(
      json.decode(result),
    );

    return resultInObject;
  }
}
