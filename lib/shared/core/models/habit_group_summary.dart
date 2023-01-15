import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';

class HabitGroupSummary {
  HabitGroupSummary({
    required this.date,
    required this.memberCount,
    required this.completeCount,
  });

  final DateTime date;
  final int memberCount;
  final int completeCount;

  factory HabitGroupSummary.fromGetGroupListCompletionItem(
    GetHabitGroupsCompletionItem item,
  ) {
    return HabitGroupSummary(
      date: DateTime.parse(item.date),
      memberCount: item.memberCount,
      completeCount: item.completeCount,
    );
  }

  factory HabitGroupSummary.fromGetGroupCompletionsItem(
    GetHabitGroupCompletionsItemResponse item,
  ) {
    return HabitGroupSummary(
      date: DateTime.parse(item.date),
      memberCount: item.memberCount,
      completeCount: item.completeCount,
    );
  }
}
