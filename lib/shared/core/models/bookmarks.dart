// ignore_for_file: file_names, unnecessary_this, prefer_collection_literals

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bookmarks.g.dart';

@JsonSerializable()
class GetBookmarkListResponse {
  GetBookmarkListResponse({
    required this.data,
    required this.message,
  });

  final List<Bookmarks> data;
  final String message;

  factory GetBookmarkListResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBookmarkListResponseFromJson(json);
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
    this.id,
    required this.surahName,
    required this.page,
    this.createdAt,
  });

  int? id;
  @JsonKey(name: 'surah_name')
  late String surahName;
  @JsonKey(name: 'created_at')
  String? createdAt;
  late int page;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    final DateTime currentTime = DateTime.now();

    if (id != null) {
      map['id'] = id;
    }
    map['surahName'] = surahName;
    map['page'] = page;
    map['createdAt'] = currentTime.toString();

    return map;
  }

  Bookmarks.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.surahName = map['surahName'];
    this.page = map['page'];
    this.createdAt = map['createdAt'];
  }

  String get createdAtFormatted {
    if (createdAt == null) {
      return '';
    }

    final DateTime currentTime = DateTime.now();
    final DateTime convertedStr = DateTime.parse(createdAt!);

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
}
