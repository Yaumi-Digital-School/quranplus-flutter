import 'package:json_annotation/json_annotation.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_favorite_ayahs.dart';

part 'favorite_ayahs.g.dart';

@JsonSerializable()
class FavoriteAyahs {
  FavoriteAyahs({
    required this.surahId,
    required this.page,
    required this.ayahSurah,
    required this.ayahHashCode,
    this.createdAt,
  });

  @JsonKey(name: 'surah_id')
  final int surahId;
  @JsonKey(name: 'ayah_surah')
  final int ayahSurah;
  @JsonKey(name: 'ayah_hash_code')
  final int ayahHashCode;
  final int page;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  String get surahName => surahNumberToSurahNameMap[surahId] ?? '';

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};
    final DateTime currentTime = DateTime.now();

    map[FavoriteAyahsTable.ayahSurah] = ayahSurah;
    map[FavoriteAyahsTable.surahId] = surahId;
    map[FavoriteAyahsTable.page] = page;
    map[FavoriteAyahsTable.ayahHashCode] = ayahHashCode;
    map[FavoriteAyahsTable.createdAt] = currentTime.toString();

    return map;
  }

  factory FavoriteAyahs.fromMap(Map<String, dynamic> map) {
    return FavoriteAyahs(
      surahId: map[FavoriteAyahsTable.surahId],
      page: map[FavoriteAyahsTable.page],
      ayahSurah: map[FavoriteAyahsTable.ayahSurah],
      createdAt: map[FavoriteAyahsTable.createdAt],
      ayahHashCode: map[FavoriteAyahsTable.ayahHashCode],
    );
  }

  factory FavoriteAyahs.fromGetListResponseItemResponse(
      GetFavoriteAyahListItemResponse item) {
    return FavoriteAyahs(
      surahId: item.surahId,
      page: item.page,
      ayahSurah: item.ayahSurah,
      ayahHashCode: int.tryParse(item.ayahHashCode) ?? 0,
    );
  }

  factory FavoriteAyahs.fromJson(Map<String, dynamic> json) =>
      _$FavoriteAyahsFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteAyahsToJson(this);
}

@JsonSerializable()
class ToggleFavoriteAyahResponse {
  ToggleFavoriteAyahResponse({
    required this.message,
  });

  @JsonKey(name: "error_message")
  final String message;

  factory ToggleFavoriteAyahResponse.fromJson(Map<String, dynamic> json) =>
      _$ToggleFavoriteAyahResponseFromJson(json);
}

@JsonSerializable()
class MergeFavoriteAyahResponse {
  MergeFavoriteAyahResponse({
    required this.message,
  });

  final String message;

  factory MergeFavoriteAyahResponse.fromJson(Map<String, dynamic> json) =>
      _$MergeFavoriteAyahResponseFromJson(json);
}

@JsonSerializable()
class GetFavoriteAyahListItemResponse {
  GetFavoriteAyahListItemResponse({
    required this.surahId,
    required this.page,
    required this.ayahSurah,
    required this.ayahHashCode,
    this.createdAt,
  });

  @JsonKey(name: 'surah_id')
  final int surahId;
  @JsonKey(name: 'ayah_surah')
  final int ayahSurah;
  @JsonKey(name: 'ayah_hash_code')
  final String ayahHashCode;
  final int page;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory GetFavoriteAyahListItemResponse.fromJson(Map<String, dynamic> json) =>
      _$GetFavoriteAyahListItemResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GetFavoriteAyahListItemResponseToJson(this);
}
