import 'dart:io';

import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:workmanager/workmanager.dart';

void scheduleAndroidPrayerTimes() {
  if (!Platform.isAndroid) return;

  Workmanager().registerOneOffTask(
    'prayerTimes-immediate',
    PrayerTimesWorker.prayerTimeReminder.name,
    tag: PrayerTimesWorker.prayerTimeReminder.tag,
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );

  Workmanager().registerPeriodicTask(
    'prayerTimes',
    PrayerTimesWorker.prayerTimeReminder.name,
    tag: PrayerTimesWorker.prayerTimeReminder.tag,
    frequency: const Duration(days: 1),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}

/// Schedules prayer time notifications for iOS directly from the foreground.
/// Schedules 7 days ahead using zonedSchedule (native iOS notification center).
/// No background task needed — iOS delivers notifications at the exact scheduled time.
Future<void> scheduleIOSPrayerNotifications({
  required SharedPreferenceService sharedPreferenceService,
}) async {
  final NotificationService notificationService = NotificationService();
  final PrayerTimesService prayerTimesService = PrayerTimesService(
    notificationService: notificationService,
    sharedPreferenceService: sharedPreferenceService,
  );
  prayerTimesService.init();
  await prayerTimesService.setupMultiDayPrayerTimesReminder();
}

Future<void> cancelTodayQuranReminders() async {
  if (Platform.isIOS) {
    final NotificationService notificationService = NotificationService();
    for (int i = 0; i < 5; i++) {
      await notificationService.cancel(reminderNotifNormalizer + i);
    }
  } else if (Platform.isAndroid) {
    await Workmanager().cancelByTag(PrayerTimesWorker.quranTimeReminder.tag);
  }
}

void scheduleQuranReadingReminder({
  required DateTime prayerTime,
  required int id,
}) {
  final DateTime sched = prayerTime.add(const Duration(minutes: 30));
  final Duration duration = sched.difference(DateTime.now());
  if (duration.isNegative) return;

  final String formattedDate = DateFormat('h:mm a').format(sched);
  Workmanager().registerOneOffTask(
    'readingReminder-$formattedDate',
    PrayerTimesWorker.quranTimeReminder.name,
    initialDelay: duration,
    tag: PrayerTimesWorker.quranTimeReminder.tag,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    inputData: <String, dynamic>{'id': id},
  );
}

Future<bool> handleWorker(String task, Map<String, dynamic>? inputData) async {
  if (task == PrayerTimesWorker.prayerTimeReminder.name) {
    try {
      final NotificationService notificationService = NotificationService();
      final SharedPreferenceService sharedPreferenceService =
          SharedPreferenceService();
      await sharedPreferenceService.init();
      await notificationService.init();
      final PrayerTimesService prayerTimesService = PrayerTimesService(
        notificationService: notificationService,
        sharedPreferenceService: sharedPreferenceService,
      );
      prayerTimesService.init();
      await prayerTimesService.setupPrayerTimesReminder();
      return true;
    } catch (_) {
      return false;
    }
  }

  if (task == PrayerTimesWorker.quranTimeReminder.name) {
    try {
      final DbLocal db = DbLocal();
      final HabitDailySummary dailySummary =
          await db.getCurrentDayHabitDailySummary();

      if (dailySummary.totalPages >= dailySummary.target) {
        await Workmanager().cancelByTag(PrayerTimesWorker.quranTimeReminder.tag);
        return true;
      }

      final int? id = inputData?['id'];
      if (id == null) return false;

      final NotificationService notificationService = NotificationService();
      await notificationService.init();
      await notificationService.show(
        id: id,
        title: "Don't miss your Quran reading goal",
        body:
            "Your Quran reading goal is within reach. Take a moment today to reflect on the wisdom of the Quran.",
      );
    } catch (_) {
      return false;
    }
  }

  return true;
}
