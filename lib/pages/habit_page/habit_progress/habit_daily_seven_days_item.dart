import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class HabitDailySevenDaysItem {
  final int? target;
  final int? totalPages;
  final DateTime date;

  HabitDailySevenDaysItem({
    required this.target,
    required this.totalPages,
    required this.date,
  });

  factory HabitDailySevenDaysItem.fromJson(Map<String, dynamic> json) {
    return HabitDailySevenDaysItem(
      target: json[HabitDailySummaryTable.target],
      totalPages: json[HabitDailySummaryTable.totalPages],
      date: DateUtils.stringToDate(
        json[HabitDailySummaryTable.date],
        DateFormatType.yyyyMMdd,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPages,
        HabitDailySummaryTable.date: date.toString(),
      };
}
