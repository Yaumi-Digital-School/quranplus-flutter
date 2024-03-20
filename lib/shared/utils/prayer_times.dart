import 'dart:io';

import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:workmanager/workmanager.dart';

void schedulePrayerTimes() {
  final DateTime dt = DateTime.now();
  final String formattedDate = DateFormat('dd-MM-yyyy').format(dt);

  if (Platform.isAndroid) {
    Workmanager().registerPeriodicTask(
      formattedDate,
      AppConstants.initPrayerTimesNotifKey,
      frequency: const Duration(days: 1),
      existingWorkPolicy: ExistingWorkPolicy.append,
    );

    return;
  }

  print('MASUK SINI');
  try {
    Workmanager().registerOneOffTask(
      AppConstants.initPrayerTimesNotifiOSKey,
      AppConstants.initPrayerTimesNotifiOSKey,
      initialDelay: const Duration(minutes: 3),
      existingWorkPolicy: ExistingWorkPolicy.append,
    );
  } catch (e) {
    print(e);
  }
}

void scheduleNextPrayerTimes() {
  final DateTime dt = DateTime.now().add(const Duration(minutes: 3));
  final String formattedDate = DateFormat('dd-MM-yyyy').format(dt);

  Workmanager().registerOneOffTask(
    AppConstants.initPrayerTimesNotifiOSKey,
    AppConstants.initPrayerTimesNotifiOSKey,
    initialDelay: const Duration(minutes: 3),
    existingWorkPolicy: ExistingWorkPolicy.append,
  );
}
