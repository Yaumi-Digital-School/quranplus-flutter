import 'package:json_annotation/json_annotation.dart';

part 'habit_sync.g.dart';

@JsonSerializable()
class HabitSyncRequest {
  HabitSyncRequest({
    this.lastSync,
    required this.dailySummaries,
  });

  final String? lastSync;
  @JsonKey(name: 'habit_daily_summaries', toJson: _Helper.dailySummariesToJson)
  final List<HabitSyncRequestDailySummaryItem> dailySummaries;

  factory HabitSyncRequest.fromJson(Map<String, dynamic> json) =>
      _$HabitSyncRequestFromJson(json);

  Map<String, dynamic> toJson() => _$HabitSyncRequestToJson(this);
}

class _Helper {
  static List<Map<String, dynamic>> dailySummariesToJson(
          List<HabitSyncRequestDailySummaryItem> dailySummaries) =>
      dailySummaries.map((e) => e.toJson()).toList();

  static List<Map<String, dynamic>> progressesToJson(
          List<HabitSyncRequestProgressItem> progresses) =>
      progresses.map((e) => e.toJson()).toList();
}

@JsonSerializable()
class HabitSyncRequestDailySummaryItem {
  HabitSyncRequestDailySummaryItem({
    required this.date,
    required this.target,
    required this.targetUpdatedAt,
    required this.progresses,
  });

  final String date;
  final int target;
  @JsonKey(name: 'target_updated_at')
  final String targetUpdatedAt;
  @JsonKey(toJson: _Helper.progressesToJson)
  final List<HabitSyncRequestProgressItem> progresses;

  factory HabitSyncRequestDailySummaryItem.fromJson(
          Map<String, dynamic> json) =>
      _$HabitSyncRequestDailySummaryItemFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HabitSyncRequestDailySummaryItemToJson(this);
}

@JsonSerializable()
class HabitSyncRequestProgressItem {
  HabitSyncRequestProgressItem({
    required this.uuid,
    required this.pages,
    required this.inputTime,
    required this.description,
    required this.type,
  });

  final String uuid;
  final int pages;
  @JsonKey(name: 'input_time')
  final String inputTime;
  final String description;
  final String type;

  factory HabitSyncRequestProgressItem.fromJson(Map<String, dynamic> json) =>
      _$HabitSyncRequestProgressItemFromJson(json);

  Map<String, dynamic> toJson() => _$HabitSyncRequestProgressItemToJson(this);
}

@JsonSerializable()
class HabitSyncResponseItem {
  HabitSyncResponseItem({
    required this.target,
    required this.totalPages,
    required this.date,
    required this.targetUpdatedAt,
    required this.habitProgresses,
  });

  final int target;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  final String date;
  @JsonKey(name: 'target_updated_at')
  final String targetUpdatedAt;
  @JsonKey(name: 'habit_progresses')
  final List<HabitSyncResponseProgressItem> habitProgresses;

  factory HabitSyncResponseItem.fromJson(Map<String, dynamic> json) =>
      _$HabitSyncResponseItemFromJson(json);

  Map<String, dynamic> toJson() => _$HabitSyncResponseItemToJson(this);
}

@JsonSerializable()
class HabitSyncResponseProgressItem {
  HabitSyncResponseProgressItem({
    required this.uuid,
    required this.pages,
    required this.description,
    required this.inputTime,
    required this.type,
  });

  final String uuid;
  final int pages;
  final String description;
  @JsonKey(name: 'input_time')
  final String inputTime;
  final String type;

  factory HabitSyncResponseProgressItem.fromJson(Map<String, dynamic> json) =>
      _$HabitSyncResponseProgressItemFromJson(json);

  Map<String, dynamic> toJson() => _$HabitSyncResponseProgressItemToJson(this);
}
