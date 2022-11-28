import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class HabitDailySummary {
  HabitDailySummary({
    this.id,
    this.target,
    this.totalPages,
    this.date,
  });
  @JsonKey(name: 'target')
  int? target;
  @JsonKey(name: 'total_pages')
  int? totalPages;
  final int? id;
  final DateTime? date;

  String get formattedDate {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date ?? DateTime(2022));
    return formattedDate;
  }

  factory HabitDailySummary.fromJson(Map<String, dynamic> json) =>
      HabitDailySummary(
        id: json[HabitDailySummaryTable.columnID],
        target: json[HabitDailySummaryTable.target],
        totalPages: json[HabitDailySummaryTable.totalPages],
        date: DateUtils.stringToDate(
          json[HabitDailySummaryTable.date],
          DateFormatType.yyyyMMdd,
        ),
      );

  Map<String, dynamic> toMap() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date ?? DateTime(2022));

    final Map<String, dynamic> map = <String, dynamic>{};
    map[HabitDailySummaryTable.columnID] = id;
    map[HabitDailySummaryTable.target] = target;
    map[HabitDailySummaryTable.totalPages] = totalPages;
    map[HabitDailySummaryTable.date] = formattedDate;

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
