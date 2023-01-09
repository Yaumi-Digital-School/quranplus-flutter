import 'package:json_annotation/json_annotation.dart';

part 'habit_group_response.g.dart';

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
