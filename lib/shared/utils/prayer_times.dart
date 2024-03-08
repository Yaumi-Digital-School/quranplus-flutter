import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:workmanager/workmanager.dart';

void schedulePrayerTimes() {
  final DateTime dt = DateTime.now();
  final String formattedDate = DateFormat('dd-MM-yyyy').format(dt);

  Workmanager().registerPeriodicTask(
    formattedDate,
    AppConstants.initPrayerTimesNotifKey,
    frequency: const Duration(days: 1),
    existingWorkPolicy: ExistingWorkPolicy.append,
  );
}
