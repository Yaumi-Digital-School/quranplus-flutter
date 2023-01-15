import 'package:json_annotation/json_annotation.dart';

part 'habit_group.g.dart';

@JsonSerializable()
class GetHabitGroupsItem {
  GetHabitGroupsItem({
    required this.id,
    required this.name,
    required this.currentMemberCount,
    required this.completions,
  });

  final int id;
  final String name;
  @JsonKey(name: 'current_member_count')
  final int currentMemberCount;
  final List<GetHabitGroupsCompletionItem> completions;

  factory GetHabitGroupsItem.fromJson(Map<String, dynamic> json) =>
      _$GetHabitGroupsItemFromJson(json);
}

@JsonSerializable()
class GetHabitGroupsCompletionItem {
  GetHabitGroupsCompletionItem({
    required this.date,
    required this.completeCount,
    required this.memberCount,
  });

  final String date;
  @JsonKey(name: 'complete_count')
  final int completeCount;
  @JsonKey(name: 'member_count')
  final int memberCount;

  factory GetHabitGroupsCompletionItem.fromJson(Map<String, dynamic> json) =>
      _$GetHabitGroupsCompletionItemFromJson(json);
}

@JsonSerializable()
class GetHabitGroupsParam {
  GetHabitGroupsParam({
    required this.startDate,
    required this.endDate,
  });

  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;

  factory GetHabitGroupsParam.fromJson(Map<String, dynamic> json) =>
      _$GetHabitGroupsParamFromJson(json);

  Map<String, dynamic> toJson() => _$GetHabitGroupsParamToJson(this);
}

@JsonSerializable()
class CreateHabitGroupRequest {
  CreateHabitGroupRequest({
    required this.name,
    required this.date,
  });

  final String name;
  final String date;

  factory CreateHabitGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateHabitGroupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateHabitGroupRequestToJson(this);
}

@JsonSerializable()
class CreateHabitGroupResponse {
  CreateHabitGroupResponse({
    required this.name,
    required this.id,
  });

  final int id;
  final String name;

  factory CreateHabitGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateHabitGroupResponseFromJson(json);
}

@JsonSerializable()
class GetHabitGroupCompletionsItemResponse {
  GetHabitGroupCompletionsItemResponse({
    required this.date,
    required this.completeCount,
    required this.memberCount,
  });

  final String date;
  @JsonKey(name: 'complete_count')
  final int completeCount;
  @JsonKey(name: 'member_count')
  final int memberCount;

  factory GetHabitGroupCompletionsItemResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetHabitGroupCompletionsItemResponseFromJson(json);
}

@JsonSerializable()
class GetHabitGroupCompletionsParam {
  GetHabitGroupCompletionsParam({
    required this.startDate,
    required this.endDate,
  });

  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;

  factory GetHabitGroupCompletionsParam.fromJson(Map<String, dynamic> json) =>
      _$GetHabitGroupCompletionsParamFromJson(json);

  Map<String, dynamic> toJson() => _$GetHabitGroupCompletionsParamToJson(this);
}

@JsonSerializable()
class GetHabitGroupMemberSummariesParam {
  GetHabitGroupMemberSummariesParam({
    required this.startDate,
    required this.endDate,
  });

  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;

  factory GetHabitGroupMemberSummariesParam.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetHabitGroupMemberSummariesParamFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GetHabitGroupMemberSummariesParamToJson(this);
}

@JsonSerializable()
class GetHabitGroupMemberPersonalItemResponse {
  GetHabitGroupMemberPersonalItemResponse({
    required this.userId,
    required this.joinDate,
    required this.name,
    required this.isAdmin,
    required this.summaries,
  });

  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'join_date')
  final String joinDate;
  final String name;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  final List<GetHabitGroupMemberPersonalSummaryItem> summaries;

  factory GetHabitGroupMemberPersonalItemResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetHabitGroupMemberPersonalItemResponseFromJson(json);
}

@JsonSerializable()
class GetHabitGroupMemberPersonalSummaryItem {
  GetHabitGroupMemberPersonalSummaryItem({
    required this.date,
    required this.target,
    required this.totalPages,
  });

  final String date;
  final int target;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  factory GetHabitGroupMemberPersonalSummaryItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetHabitGroupMemberPersonalSummaryItemFromJson(json);
}
