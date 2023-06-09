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
class GetListTadabburSurahAvailable {
  GetListTadabburSurahAvailable(this.surahID, this.totalTadabbur);

  @JsonKey(name: 'id')
  final int surahID;
  @JsonKey(name: 'total_tadabbur')
  final int totalTadabbur;

  factory GetListTadabburSurahAvailable.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GetListTadabburSurahAvailableFromJson(json);
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
  @JsonKey(name: 'indonesia_name')
  final String indonesianName;

  Surah({required this.indonesianName});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return _$SurahFromJson(json);
  }
}

@JsonSerializable()
class TadabburItemResponse {
  final int id;
  final String title;
  @JsonKey(name: 'surah_id')
  final int surahId;
  @JsonKey(name: 'ayah_number')
  final int ayahNumber;
  @JsonKey(name: 'source_type')
  final String sourceType;
  @JsonKey(name: 'source_id')
  final int sourceId;
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
    required this.sourceId,
  });

  factory TadabburItemResponse.fromJson(Map<String, dynamic> json) {
    return _$TadabburItemResponseFromJson(json);
  }
}

@JsonSerializable()
class TadabburContentItem {
  @JsonKey(name: 'content_type')
  final String contentType;
  final String content;

  TadabburContentItem({required this.content, required this.contentType});

  factory TadabburContentItem.fromJson(Map<String, dynamic> json) {
    return _$TadabburContentItemFromJson(json);
  }
}

class TadabburContentReadingInfo {
  TadabburContentReadingInfo({
    required this.tadabburID,
    required this.content,
    this.latestReadIndex = 0,
  });

  TadabburContentResponse content;
  int latestReadIndex;
  int tadabburID;
}

@JsonSerializable()
class TadabburContentResponse {
  final String? title;
  @JsonKey(name: 'ayah_number')
  final int? ayahNumber;
  @JsonKey(name: 'surah_id')
  final int? surahNumber;
  @JsonKey(name: 'tadabbur_contents')
  final List<TadabburContentItem>? tadabburContent;
  @JsonKey(name: 'next_tadabbur_id')
  final int? nextTadabburId;
  @JsonKey(name: 'previous_tadabbur_id')
  final int? previousTadabburId;
  @JsonKey(name: 'surah')
  final TadabburContentResponseSurah? surahInfo;

  final bool shouldClosePage;

  TadabburContentResponse({
    this.ayahNumber,
    this.surahNumber,
    this.tadabburContent,
    this.title,
    this.surahInfo,
    this.nextTadabburId,
    this.previousTadabburId,
    this.shouldClosePage = false,
  });

  factory TadabburContentResponse.fromJson(Map<String, dynamic> json) {
    return _$TadabburContentResponseFromJson(json);
  }
}

@JsonSerializable()
class TadabburContentResponseSurah {
  TadabburContentResponseSurah({
    required this.surahName,
  });

  @JsonKey(name: 'indonesia_name')
  final String surahName;

  factory TadabburContentResponseSurah.fromJson(Map<String, dynamic> json) {
    return _$TadabburContentResponseSurahFromJson(json);
  }
}

@JsonSerializable()
class GetListOfAvailableTadabburAyah {
  GetListOfAvailableTadabburAyah(this.result);

  final Map<int, List<int>> result;

  factory GetListOfAvailableTadabburAyah.fromJson(Map<int, List<int>> json) {
    return GetListOfAvailableTadabburAyah(json);
  }
}
