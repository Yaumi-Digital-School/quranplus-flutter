import 'package:json_annotation/json_annotation.dart';

part 'audio.g.dart';

@JsonSerializable()
class AudioSpecificAyahResponse {
  AudioSpecificAyahResponse({required this.audioFileUrl});

  @JsonKey(name: 'audio_file_url')
  final String audioFileUrl;

  factory AudioSpecificAyahResponse.fromJson(Map<String, dynamic> json) =>
      _$AudioSpecificAyahResponseFromJson(json);
}
