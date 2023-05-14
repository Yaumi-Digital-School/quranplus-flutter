import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/src/flutter_local_notifications_plugin.dart';
import 'package:qurantafsir_flutter/main.dart';
import 'package:qurantafsir_flutter/shared/constants/adhan_config.dart';
import 'package:qurantafsir_flutter/shared/utils/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _enableAlarmNotification(PrayerTimes prayerTimes, int prayerIndex) {
  Prayer prayer = Prayer.values[prayerIndex];
  DateTime? prayerTime = prayerTimes.timeForPrayer(prayer);

  if (prayerTime != null) {
    scheduleNotification(
        flutterLocalNotificationsPlugin,
        prayerIndex,
        prayer.toString(),
        'Salah Reminder',
        'Time for Salah: ' +
            prayerNames[prayerIndex] +
            ', at ' +
            prayerTime.hour.toString() +
            ':' +
            prayerTime.minute.toString(),
        prayerTime);
  }
}

void setAlarmNotification(
    PrayerTimes prayerTimes, int prayerIndex, bool enableFlag) {
  turnOffNotificationById(flutterLocalNotificationsPlugin, prayerIndex);
  if (enableFlag) {
    _enableAlarmNotification(prayerTimes, prayerIndex);
  }
}

Future<void> saveAlarmFlag(int index, bool flag) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('alarm$index', flag);
}

Future<bool> getAlarmFlag(int index) async {
  bool flag = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('alarm$index')) {
    flag = prefs.getBool('alarm$index')!;
  }

  return flag;
}
