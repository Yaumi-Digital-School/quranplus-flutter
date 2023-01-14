import 'package:json_annotation/json_annotation.dart';

part 'habit_group.g.dart';

@JsonSerializable()
class GetHabitGroupsResponse {
  GetHabitGroupsResponse({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory GetHabitGroupsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetHabitGroupsResponseFromJson(json);
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
