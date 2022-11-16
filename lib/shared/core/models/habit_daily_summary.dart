import 'package:json_annotation/json_annotation.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';

class HabitDailySummary {
  HabitDailySummary({
    required this.target,
    required this.totalPage,
  });
  @JsonKey(name: 'target')
  int? target;
  @JsonKey(name: 'total_pages')
  int? totalPage;

  factory HabitDailySummary.fromJson(Map<String, dynamic> json) =>
      HabitDailySummary(
        target: json[HabitDailySummaryTable.target],
        totalPage: json[HabitDailySummaryTable.totalPages],
      );

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    final DateTime currentTime = DateTime.now();

    map[HabitDailySummaryTable.target] = target;
    map[HabitDailySummaryTable.totalPages] = totalPage;
    return map;
  }

  Map<String, dynamic> toJson() => {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPage,
      };

  factory HabitDailySummary.fromMap(Map<String, dynamic> map) {
    return HabitDailySummary(
      target: map[HabitDailySummaryTable.target],
      totalPage: map[HabitDailySummaryTable.totalPages],
    );
  }
}
