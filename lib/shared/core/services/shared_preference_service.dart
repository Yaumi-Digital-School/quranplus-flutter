import 'dart:convert';
import 'dart:developer';

import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  late SharedPreferences _sharedPreferences;

  final String _readingSettingsKey = 'reading-settings';
  final String _apiTokenKey = "api-token";
  final String _usernameKey = "username-token";

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

  Future<void> setApiToken(String? token) async {
    _sharedPreferences.setString(_apiTokenKey, token ?? '');
  }

  String getApiToken() {
    return _sharedPreferences.getString(_apiTokenKey) ?? '';
  }

  Future<bool> removeApiToken() async {
    var isRemoved = await _sharedPreferences.remove(_apiTokenKey);
    return isRemoved;
  }

  Future<void> setUsername(String? name) async {
    _sharedPreferences.setString(_usernameKey, name ?? '');
  }

  String getUsername() {
    return _sharedPreferences.getString(_usernameKey) ?? '';
  }

  Future<bool> removeUsername() async {
    var isRemoved = await _sharedPreferences.remove(_usernameKey);
    return isRemoved;
  }
}
