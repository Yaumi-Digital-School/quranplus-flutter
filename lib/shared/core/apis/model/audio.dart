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

@JsonSerializable()
class ListReciterResponse {
  final int id;
  @JsonKey(name: 'name')
  final String name;

  ListReciterResponse({required this.id, required this.name});

  factory ListReciterResponse.fromjson(Map<String, dynamic> json) {
    return _$ListReciterResponseFromJson(json);
  }
}
