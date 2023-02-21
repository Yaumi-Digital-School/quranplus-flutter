import 'dart:convert';

import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  late SharedPreferences _sharedPreferences;

  final String _readingSettingsKey = 'reading-settings';
  final String _apiTokenKey = "api-token";
  final String _usernameKey = "username-token";
  final String _forceLoginParam = "force-login-param";
  final String _lastSync = "last-sync";
  final String _habitNeedToSyncTimer = "habit-need-to-sync-timer";

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

  Future<void> setLastSync(DateTime date) async {
    final formattedLastSync = DateCustomUtils.formatISOTime(date);
    await _sharedPreferences.setString(_lastSync, formattedLastSync);
  }

  Future<void> setHabitNeedToSyncTimer(DateTime? date) async {
    if (date == null) {
      await _sharedPreferences.setString(_habitNeedToSyncTimer, "");

      return;
    }
    final formattedDate = DateCustomUtils.formatISOTime(date);
    await _sharedPreferences.setString(_habitNeedToSyncTimer, formattedDate);
  }

  String getLastSync() {
    return _sharedPreferences.getString(_lastSync) ?? '';
  }

  String getHabitNeedToSyncTimer() {
    return _sharedPreferences.getString(_habitNeedToSyncTimer) ?? "";
  }

  Future<bool> removeLastSync() async {
    return await _sharedPreferences.remove(_lastSync);
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

  Future<void> setForceLoginParam(ForceLoginParam param) async {
    final String encodedParam = json.encode(param.toJson());
    await _sharedPreferences.setString(_forceLoginParam, encodedParam);
  }

  Future<void> removeForceLoginParam() async {
    await _sharedPreferences.remove(_forceLoginParam);
  }

  Future<ForceLoginParam?> getForceLoginParam() async {
    final String res = _sharedPreferences.getString(_forceLoginParam) ?? '';
    if (res.isEmpty) {
      return null;
    }

    return ForceLoginParam.fromJson(
      json.decode(res),
    );
  }
}
