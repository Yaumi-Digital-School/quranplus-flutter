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
