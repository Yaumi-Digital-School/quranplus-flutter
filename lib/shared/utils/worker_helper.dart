import 'package:adhan/adhan.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_alarm_helper.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_time_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'geolocation_helper.dart';

final workManager = Workmanager();
const updatePrayerTimeTaskID = '199';
const updatePrayerTimeTaskName = 'updatePrayerTimeTask';

void callbackDispatcher() {
  workManager.executeTask((task, inputData) async {
    switch (task) {
      case updatePrayerTimeTaskName:
        await _saveWorkerLastRunDate(DateTime.now());
        await _updateAlarmBackgroundFunc(inputData);
        break;
    }

    return Future.value(true);
  });
}

Future<bool> _saveWorkerLastRunDate(DateTime dateIn) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return await prefs.setString('workerManager', dateIn.toString());
}

Future<void> _updateAlarmBackgroundFunc(inputData) async {
  final Coordinates coords = await getSavedCoordinates();
  final CalculationParameters params = await getPrayerParams();
  final PrayerTimes prayerTimes = PrayerTimes.today(coords, params);

  for (var p in Prayer.values) {
    if (await getAlarmFlag(p.index)) {
      setAlarmNotification(prayerTimes, p.index, true);
    }
  }
}

Future<void> initWorkerManager() async {
  await workManager.initialize(
    callbackDispatcher,
    // isInDebugMode: true,
  );
}

Future<void> cancelAllTask() async {
  await workManager.cancelAll();
}

Future<void> cancelTask(String id) async {
  await workManager.cancelByUniqueName(id);
}

Future<void> enablePeriodicTask(String id, String taskName, Duration duration,
    Map<String, dynamic> inputData) async {
  await workManager.registerPeriodicTask(id, taskName,
      frequency: duration,
      inputData: inputData,
      existingWorkPolicy: ExistingWorkPolicy.replace);
}

Future<String> getWorkerLastRunDate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('workerManager')) {
    return prefs.getString('workerManager')!;
  }

  return 'Not Found';
}
