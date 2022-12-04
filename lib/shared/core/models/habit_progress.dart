import 'package:qurantafsir_flutter/shared/core/database/db_habit_progress.dart';

class HabitProgress {
  final int? columnID;
  final String uuid;
  final int pages;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int habitDailySummaryID;
  final String inputTime;
  final String type;

  const HabitProgress({
    this.columnID,
    required this.uuid,
    required this.pages,
    required this.description,
    this.createdAt,
    this.updatedAt,
    required this.habitDailySummaryID,
    required this.inputTime,
    required this.type,
  });

  factory HabitProgress.fromJson(Map<String, dynamic> json) {
    final parseUpdateTime = json[HabitProgressTable.updatedAt] == null
        ? null
        : DateTime.parse(json[HabitProgressTable.updatedAt]);

    return HabitProgress(
      columnID: json[HabitProgressTable.columnID],
      uuid: json[HabitProgressTable.uuid],
      pages: json[HabitProgressTable.pages],
      description: json[HabitProgressTable.description],
      createdAt: DateTime.parse(json[HabitProgressTable.createdAt]),
      updatedAt: parseUpdateTime,
      habitDailySummaryID: json[HabitProgressTable.habitDailySummaryID],
      inputTime: json[HabitProgressTable.inputTime],
      type: json[HabitProgressTable.type],
    );
  }
}
