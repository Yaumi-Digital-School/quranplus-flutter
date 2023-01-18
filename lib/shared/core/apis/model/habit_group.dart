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
class UpdateHabitGroupRequest {
  UpdateHabitGroupRequest({
    required this.newName,
  });

  @JsonKey(name: 'new_name')
  final String newName;

  factory UpdateHabitGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateHabitGroupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateHabitGroupRequestToJson(this);
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
class GetHabitGroupDetailResponse {
  GetHabitGroupDetailResponse({
    required this.name,
    required this.createdAt,
    required this.completions,
  });

  final String name;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<GetHabitGroupDetailCompletionItem> completions;

  factory GetHabitGroupDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetHabitGroupDetailResponseFromJson(json);
}

@JsonSerializable()
class GetHabitGroupDetailCompletionItem {
  GetHabitGroupDetailCompletionItem({
    required this.date,
    required this.completeCount,
    required this.memberCount,
  });

  final String date;
  @JsonKey(name: 'complete_count')
  final int completeCount;
  @JsonKey(name: 'member_count')
  final int memberCount;

  factory GetHabitGroupDetailCompletionItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetHabitGroupDetailCompletionItemFromJson(json);
}

@JsonSerializable()
class GetHabitGroupDetailParam {
  GetHabitGroupDetailParam({
    required this.startDate,
    required this.endDate,
  });

  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;

  factory GetHabitGroupDetailParam.fromJson(Map<String, dynamic> json) =>
      _$GetHabitGroupDetailParamFromJson(json);

  Map<String, dynamic> toJson() => _$GetHabitGroupDetailParamToJson(this);
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
  final DateTime joinDate;
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

@JsonSerializable()
class JoinHabitGroupRequest {
  JoinHabitGroupRequest({
    required this.date,
  });

  final String date;

  factory JoinHabitGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinHabitGroupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JoinHabitGroupRequestToJson(this);
}

class JoinHabitGroupResponse {
  final bool successJoin;
  JoinHabitGroupResponse({required this.successJoin});

  factory JoinHabitGroupResponse.fromJson(dynamic success) {
    if (success is bool) {
      return JoinHabitGroupResponse(successJoin: success);
    }

    return JoinHabitGroupResponse(successJoin: false);
  }
}

@JsonSerializable()
class LeaveHabitGroupRequest {
  LeaveHabitGroupRequest({
    required this.date,
  });

  final String date;

  factory LeaveHabitGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveHabitGroupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveHabitGroupRequestToJson(this);
}
