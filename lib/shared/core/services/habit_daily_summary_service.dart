import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_sync.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';

class HabitDailySummaryService {
  final SharedPreferenceService sharedPreferenceService;
  final DbLocal _db = DbLocal();

  HabitDailySummaryService({required this.sharedPreferenceService});

  Future<HabitDailySummary> getCurrentDayHabitDailySummaryListLocal() async {
    final HabitDailySummary result = await _db.getCurrentDayHabitDailySummary();
    return result;
  }

  Future<HabitSyncRequest> getLocalDataRequest() async {
    final resultHabitDailySummaries =
        await _db.getLocalDbToSync(sharedPreferenceService);
    final lastSync = sharedPreferenceService.getLastSync();
    return HabitSyncRequest(
      dailySummaries: resultHabitDailySummaries,
      lastSync: lastSync.isEmpty ? null : lastSync,
    );
  }
}
