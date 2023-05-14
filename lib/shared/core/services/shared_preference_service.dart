import 'dart:convert';

import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/last_recording_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  late SharedPreferences _sharedPreferences;
  static const String isAlreadyOnBoardingTadabbur =
      "is-already-on-boarding-tadabbur";

  final String _readingSettingsKey = 'reading-settings';
  final String _apiTokenKey = "api-token";
  final String _usernameKey = "username-token";
  final String _forceLoginParam = "force-login-param";
  final String _lastSync = "last-sync";
  final String _habitNeedToSyncTimer = "habit-need-to-sync-timer";
  final String _lastSyncTadabburInformation = "last-sync-tadabbur-information";
  final String _lastRecordingData = "last-recording-data";
  final String _latitude = "latitude";
  final String _longitude = "lognitude";

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

  Future<void> setAlreadyOnBoarding(String key) async {
    _sharedPreferences.setBool(key, true);
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

  Future<void> setLastSyncTadabburInformation(DateTime date) async {
    final formattedLastSync = DateCustomUtils.formatISOTime(date);
    await _sharedPreferences.setString(
      _lastSyncTadabburInformation,
      formattedLastSync,
    );
  }

  String getLastSyncTadabburInformation() {
    return _sharedPreferences.getString(_lastSyncTadabburInformation) ?? '';
  }

  String getLastSync() {
    final String defaultLastSync =
        DateCustomUtils.getFirstDayOfTheWeekFromToday();

    return _sharedPreferences.getString(_lastSync) ?? defaultLastSync;
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

  String getLatitude() {
    return _sharedPreferences.getDouble(_latitude)?.toString() ?? '';
  }

  String getLongitude() {
    return _sharedPreferences.getDouble(_longitude)?.toString() ?? '';
  }

  bool getIsAlreadyOnBoarding(String key) {
    return _sharedPreferences.getBool(key) ?? false;
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

  Future<void> setLastRecordingData(LastRecordingData data) async {
    final String encodedParam = json.encode(data.toJson());
    await _sharedPreferences.setString(_lastRecordingData, encodedParam);
  }

  Future<LastRecordingData?> getLastRecordingData() async {
    final String res = _sharedPreferences.getString(_lastRecordingData) ?? '';
    if (res.isEmpty) {
      return null;
    }

    return LastRecordingData.fromJson(
      json.decode(res),
    );
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }
}
