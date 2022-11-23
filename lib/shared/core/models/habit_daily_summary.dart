import 'package:json_annotation/json_annotation.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class HabitDailySummary {
  HabitDailySummary({
    required this.target,
    required this.totalPages,
    required this.date,
  });
  @JsonKey(name: 'target')
  int? target;
  @JsonKey(name: 'total_pages')
  int? totalPages;
  final DateTime? date;

  factory HabitDailySummary.fromJson(Map<String, dynamic> json) =>
      HabitDailySummary(
        target: json[HabitDailySummaryTable.target],
        totalPages: json[HabitDailySummaryTable.totalPages],
        date: DateUtils.stringToDate(
          json[HabitDailySummaryTable.date],
          DateFormatType.yyyyMMdd,
        ),
      );

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map[HabitDailySummaryTable.target] = target;
    map[HabitDailySummaryTable.totalPages] = totalPages;
    return map;
  }

  Map<String, dynamic> toJson() => {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPages,
      };

  factory HabitDailySummary.fromMap(Map<String, dynamic> map) {
    return HabitDailySummary(
      target: map[HabitDailySummaryTable.target],
      totalPages: map[HabitDailySummaryTable.totalPages],
      date: DateUtils.stringToDate(
        map[HabitDailySummaryTable.date],
        DateFormatType.yyyyMMdd,
      ),
    );
  }
}
