import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:workmanager/workmanager.dart';

void schedulePrayerTimes() {
  final DateTime dt = DateTime.now();
  final String formattedDate = DateFormat('h:mm a').format(dt);

  Workmanager().registerPeriodicTask(
    'prayerTimes-$formattedDate',
    PrayerTimesWorker.prayerTimeReminder.name,
    tag: PrayerTimesWorker.prayerTimeReminder.tag,
    frequency: const Duration(days: 1),
    existingWorkPolicy: ExistingWorkPolicy.append,
  );
}

void scheduleQuranReadingReminder({
  required DateTime prayerTime,
  required int id,
}) {
  final DateTime sched = prayerTime.add(const Duration(minutes: 30));
  final String formattedDate = DateFormat('h:mm a').format(sched);
  final Duration duration = sched.difference(DateTime.now());

  Workmanager().registerOneOffTask(
    'readingReminder-$formattedDate',
    PrayerTimesWorker.quranTimeReminder.name,
    initialDelay: duration,
    tag: PrayerTimesWorker.quranTimeReminder.tag,
    existingWorkPolicy: ExistingWorkPolicy.append,
    inputData: <String, dynamic>{
      'id': id,
    },
  );
}

Future<bool> handleWorker(String task, Map<String, dynamic>? inputData) async {
  if (task == PrayerTimesWorker.prayerTimeReminder.name) {
    final NotificationService notificationService = NotificationService();
    final PrayerTimesService prayerTimesService = PrayerTimesService(
      notificationService: notificationService,
    );
    prayerTimesService.init();
    await notificationService.init();
    await prayerTimesService.setupPrayerTimesReminder();

    return Future.value(true);
  }

  if (task == PrayerTimesWorker.quranTimeReminder.name) {
    final DbLocal db = DbLocal();
    final HabitDailySummary dailySummary =
        await db.getCurrentDayHabitDailySummary();
    if (dailySummary.totalPages >= dailySummary.target) {
      Workmanager().cancelByTag(PrayerTimesWorker.quranTimeReminder.tag);

      return Future.value(true);
    }

    if (dailySummary.totalPages < dailySummary.target) {
      final NotificationService notificationService = NotificationService();
      final PrayerTimesService prayerTimesService = PrayerTimesService(
        notificationService: notificationService,
      );
      prayerTimesService.init();
      await notificationService.init();

      final int? id = inputData != null ? inputData['id'] : null;
      if (id == null) return Future.value(false);

      notificationService.show(
        id: id,
        title: "Don't miss your Quran reading goal",
        body:
            "Your Quran reading goal is within reach. Take a moment today to reflect on the wisdom of the Quran.",
      );
    }
  }

  return Future.value(true);
}
