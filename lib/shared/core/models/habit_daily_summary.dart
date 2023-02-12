import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class HabitDailySummary {
  HabitDailySummary({
    required this.target,
    required this.totalPages,
    required this.date,
    this.id,
    this.targetUpdatedTime,
    this.createdAt,
    this.updatedAt,
  });

  final int target;
  final int totalPages;
  final DateTime date;
  final int? id;
  final String? targetUpdatedTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory HabitDailySummary.fromJson(Map<String, dynamic> json) {
    final createdAtString = json[HabitDailySummaryTable.createdAt];
    final updateAtString = json[HabitDailySummaryTable.updatedAt];

    return HabitDailySummary(
      target: json[HabitDailySummaryTable.target],
      totalPages: json[HabitDailySummaryTable.totalPages],
      date: DateUtils.stringToDate(
        json[HabitDailySummaryTable.date],
        DateFormatType.yyyyMMdd,
      ),
      id: json[HabitDailySummaryTable.columnID],
      targetUpdatedTime: json[HabitDailySummaryTable.targetUpdatedTime],
      createdAt:
          createdAtString == null ? null : DateTime.parse(createdAtString),
      updatedAt: updateAtString == null ? null : DateTime.parse(updateAtString),
    );
  }

  Map<String, dynamic> toMap() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);

    final Map<String, dynamic> map = <String, dynamic>{};
    map[HabitDailySummaryTable.columnID] = id;
    map[HabitDailySummaryTable.target] = target;
    map[HabitDailySummaryTable.totalPages] = totalPages;
    map[HabitDailySummaryTable.date] = formattedDate;
    map[HabitDailySummaryTable.targetUpdatedTime] = targetUpdatedTime;

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

  String get formattedDate {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);

    return formattedDate;
  }

  factory HabitDailySummary.fromGetHabitGroupMemberPersonalSummaryItem(
    GetHabitGroupMemberPersonalSummaryItem item,
  ) {
    return HabitDailySummary(
      target: item.target,
      totalPages: item.totalPages,
      date: DateTime.parse(item.date),
    );
  }
}
