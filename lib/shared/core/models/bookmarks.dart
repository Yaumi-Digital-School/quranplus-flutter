// ignore_for_file: file_names, unnecessary_this, prefer_collection_literals

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';

part 'bookmarks.g.dart';

@JsonSerializable()
class GetBookmarkListResponse {
  GetBookmarkListResponse({
    this.data,
    required this.message,
  });

  final List<Bookmarks>? data;
  final String message;

  factory GetBookmarkListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBookmarkListResponseFromJson(json);
}

@JsonSerializable()
class MergeBookmarkRequest {
  MergeBookmarkRequest({
    required this.surahID,
    required this.createdAt,
    required this.page,
  });

  @JsonKey(name: 'surah_id')
  int surahID;
  @JsonKey(name: 'created_at')
  String createdAt;
  int page;

  Map<String, dynamic> toJson() => _$MergeBookmarkRequestToJson(this);
}

@JsonSerializable()
class CreateBookmarkResponse {
  CreateBookmarkResponse({
    required this.message,
  });

  @JsonKey(name: "error_message")
  final String message;

  factory CreateBookmarkResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateBookmarkResponseFromJson(json);
}

@JsonSerializable()
class CreateBookmarkRequest {
  CreateBookmarkRequest({
    required this.page,
    this.surahId,
  });

  @JsonKey(name: 'surah_id', includeIfNull: false)
  final int? surahId;
  final int page;

  factory CreateBookmarkRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookmarkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookmarkRequestToJson(this);
}

@JsonSerializable()
class Bookmarks {
  Bookmarks({
    this.surahID,
    required this.surahName,
    required this.page,
    this.createdAt,
  });

  @JsonKey(name: 'surah_id')
  int? surahID;
  @JsonKey(name: 'surah_name')
  late String surahName;
  @JsonKey(name: 'created_at')
  String? createdAt;
  late int page;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    final DateTime currentTime = DateTime.now();

    map['surahName'] = surahName;
    map['page'] = page;
    map['createdAt'] = currentTime.toString();

    return map;
  }

  Map<String, dynamic> toMapAfterMergeToServer() {
    var map = Map<String, dynamic>();

    map['surahName'] = surahNumberToSurahNameMap[surahID];
    map['page'] = page;
    map['createdAt'] = createdAt;

    return map;
  }

  Bookmarks.fromMap(Map<String, dynamic> map) {
    this.surahName = map['surahName'];
    this.page = map['page'];
    this.createdAt = map['createdAt'];
  }

  String get createdAtFormatted {
    if (createdAt == null) {
      return '';
    }

    final DateTime currentTime = DateTime.now();
    final DateTime convertedStr = DateTime.parse(createdAt!).add(
      const Duration(hours: 7), // TODO(yumnanaruto): temporary fix
    );

    final Duration timeDiffInDay = DateUtils.dateOnly(currentTime).difference(
      DateUtils.dateOnly(convertedStr),
    );

    if (timeDiffInDay < const Duration(days: 1)) {
      return '${convertedStr.hour}:${convertedStr.minute.toString().padLeft(2, "0")}';
    }

    if (timeDiffInDay <= const Duration(days: 7)) {
      return '${timeDiffInDay.inDays} Days Ago';
    }

    return '${convertedStr.day}-${convertedStr.month}-${convertedStr.year}';
  }

  factory Bookmarks.fromJson(Map<String, dynamic> json) =>
      _$BookmarksFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarksToJson(this);
}
