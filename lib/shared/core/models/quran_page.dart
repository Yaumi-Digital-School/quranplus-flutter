import 'package:json_annotation/json_annotation.dart';

part 'quran_page.g.dart';

@JsonSerializable()
class QuranPage {
  QuranPage({required this.verses});

  List<Verse> verses;

  factory QuranPage.fromJson(Map<String, dynamic> json) =>
      _$QuranPageFromJson(json);

  factory QuranPage.fromArray(List<dynamic> arr) {
    List<Verse> verses = <Verse>[];
    arr.forEach((dynamic element) {
      Map<String, dynamic> v = element as Map<String, dynamic>;
      Verse verse = Verse.fromJson(v);

      verses.add(verse);
    });

    return QuranPage(verses: verses);
  }
}

@JsonSerializable()
class Verse {
  Verse({
    required this.hizbNumber,
    required this.id,
    required this.juzNumber,
    required this.verseKey,
    required this.verseNumber,
    required this.words,
  });

  @JsonKey(name: 'hizb_number')
  int hizbNumber;
  int id;
  @JsonKey(name: 'juz_number')
  int juzNumber;
  @JsonKey(name: 'verse_key')
  String verseKey;
  @JsonKey(name: 'verse_number')
  int verseNumber;
  List<Word> words;

  int get surahNumber => int.parse(verseKey.split(":")[0]);
  int get surahNumberInIndex => surahNumber - 1;
  int get verseNumberInIndex => verseNumber - 1;

  int get uniqueVerseIndex => verseNumber + (surahNumber * 20);

  factory Verse.fromJson(Map<String, dynamic> json) => _$VerseFromJson(json);
}

@JsonSerializable()
class Word {
  Word({
    required this.chapterNumber,
    required this.code,
    required this.id,
    required this.lineNumber,
    required this.wordPosition,
  });

  @JsonKey(name: 'chapter_number')
  int chapterNumber;
  @JsonKey(name: 'code_v1')
  String code;
  int id;
  @JsonKey(name: 'line_number')
  int lineNumber;
  @JsonKey(name: 'position')
  int wordPosition;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
