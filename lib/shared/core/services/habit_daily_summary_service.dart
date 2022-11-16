import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';

class HabitDailySummaryService {
  final DbLocal _db = DbLocal();

  Future<HabitDailySummary> getCurrentDayHabitDailySummaryListLocal() async {
    final HabitDailySummary result = await _db.getCurrentDayHabitDailySummary();
    return result;
  }
}
