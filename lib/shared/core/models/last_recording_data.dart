import 'package:json_annotation/json_annotation.dart';

part 'last_recording_data.g.dart';

@JsonSerializable()
class LastRecordingData {
  LastRecordingData({
    required this.surahName,
    required this.page,
  });

  factory LastRecordingData.fromJson(Map<String, dynamic> json) =>
      _$LastRecordingDataFromJson(json);

  Map<String, dynamic> toJson() => _$LastRecordingDataToJson(this);

  final String surahName;
  final int page;
}
