import 'package:json_annotation/json_annotation.dart';

part 'tadabbur.g.dart';

@JsonSerializable()
class GetTadabburSurahListItemResponse {
  GetTadabburSurahListItemResponse({
    required this.totalTadabbur,
    required this.surahID,
    required this.createdAt,
    required this.surah,
  });

  @JsonKey(name: 'total_tadabbur')
  final int totalTadabbur;
  @JsonKey(name: 'surah_id')
  final int surahID;
  final DateTime createdAt;
  final GetTadabburSurahListItemSurah surah;

  factory GetTadabburSurahListItemResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetTadabburSurahListItemResponseFromJson(json);
}

@JsonSerializable()
class GetTadabburSurahListItemSurah {
  GetTadabburSurahListItemSurah({
    required this.name,
  });

  @JsonKey(name: 'indonesia_name')
  final String name;

  factory GetTadabburSurahListItemSurah.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetTadabburSurahListItemSurahFromJson(json);
}

@JsonSerializable()
class Source {
  final String name;
  Source({required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return _$SourceFromJson(json);
  }
}

@JsonSerializable()
class Surah {
  @JsonKey(name: 'indonesian_name')
  final String indonesianName;

  Surah({required this.indonesianName});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return _$SurahFromJson(json);
  }
}

@JsonSerializable()
class TadabburItemResponse {
  final String id;
  final String title;
  @JsonKey(name: 'surah_id')
  final String surahId;
  @JsonKey(name: 'ayah_number')
  final String ayahNumber;
  @JsonKey(name: 'source_type')
  final String sourceType;
  final DateTime createdAt;
  final Source source;
  final Surah surah;

  TadabburItemResponse({
    required this.ayahNumber,
    required this.createdAt,
    required this.id,
    required this.source,
    required this.sourceType,
    required this.surah,
    required this.surahId,
    required this.title,
  });

  factory TadabburItemResponse.fromJson(Map<String, dynamic> json) {
    return _$TadabburItemResponseFromJson(json);
  }
}
