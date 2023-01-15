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
