import 'package:json_annotation/json_annotation.dart';
part 'user_summary.g.dart';

@JsonSerializable()
class UserSummaryRequest {
  final String date;

  UserSummaryRequest({required this.date});

  Map<String, dynamic> toJson() => _$UserSummaryRequestToJson(this);
}

@JsonSerializable()
class UserSummaryResponse {
  final int target;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  final String date;
  final UserOnlyName user;
  @JsonKey(name: 'habit_progresses')
  final List<UserHabitProgress> habitProgresses;

  UserSummaryResponse({
    required this.date,
    required this.habitProgresses,
    required this.target,
    required this.totalPages,
    required this.user,
  });

  factory UserSummaryResponse.fromJson(Map<String, dynamic> json) {
    return _$UserSummaryResponseFromJson(json);
  }
}

@JsonSerializable()
class UserOnlyName {
  final String name;

  UserOnlyName({required this.name});

  factory UserOnlyName.fromJson(Map<String, dynamic> json) {
    return _$UserOnlyNameFromJson(json);
  }
}

@JsonSerializable()
class UserHabitProgress {
  final int pages;
  final String description;
  final String type;
  @JsonKey(name: 'input_time')
  final String inputTime;

  UserHabitProgress({
    required this.pages,
    required this.description,
    required this.type,
    required this.inputTime,
  });

  factory UserHabitProgress.fromJson(Map<String, dynamic> json) {
    return _$UserHabitProgressFromJson(json);
  }
}
