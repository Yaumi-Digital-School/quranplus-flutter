// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuranPage _$QuranPageFromJson(Map<String, dynamic> json) => QuranPage(
      verses: (json['verses'] as List<dynamic>)
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuranPageToJson(QuranPage instance) => <String, dynamic>{
      'verses': instance.verses,
    };

Verse _$VerseFromJson(Map<String, dynamic> json) => Verse(
      hizbNumber: json['hizb_number'] as int,
      id: json['id'] as int,
      juzNumber: json['juz_number'] as int,
      verseKey: json['verse_key'] as String,
      verseNumber: json['verse_number'] as int,
      words: (json['words'] as List<dynamic>)
          .map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VerseToJson(Verse instance) => <String, dynamic>{
      'hizb_number': instance.hizbNumber,
      'id': instance.id,
      'juz_number': instance.juzNumber,
      'verse_key': instance.verseKey,
      'verse_number': instance.verseNumber,
      'words': instance.words,
    };

Word _$WordFromJson(Map<String, dynamic> json) => Word(
      chapterNumber: json['chapter_number'] as int,
      code: json['code_v1'] as String,
      id: json['id'] as int,
      lineNumber: json['line_number'] as int,
      wordPosition: json['position'] as int,
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'chapter_number': instance.chapterNumber,
      'code_v1': instance.code,
      'id': instance.id,
      'line_number': instance.lineNumber,
      'position': instance.wordPosition,
    };
