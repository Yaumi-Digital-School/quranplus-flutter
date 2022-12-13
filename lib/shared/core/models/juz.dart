import 'dart:convert';

Juz juzFromJson(String str) => Juz.fromJson(json.decode(str));

String juzToJson(Juz data) => json.encode(data.toJson());

class Juz {
  Juz({
    required this.juz,
  });

  List<JuzElement> juz;

  factory Juz.fromJson(Map<String, dynamic> json) => Juz(
        juz: List<JuzElement>.from(
          json["juz"].map((x) => JuzElement.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "juz": List<dynamic>.from(juz.map((x) => x.toJson())),
      };
}

class JuzElement {
  JuzElement({
    required this.number,
    required this.name,
    required this.surat,
  });

  String number;
  String name;
  List<SuratByJuz> surat;

  factory JuzElement.fromJson(Map<String, dynamic> json) => JuzElement(
        number: json["number"],
        name: json["name"],
        surat: List<SuratByJuz>.from(
          json["surat"].map((x) => SuratByJuz.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "surat": List<dynamic>.from(surat.map((x) => x.toJson())),
      };
}

class SuratByJuz {
  SuratByJuz({
    required this.number,
    required this.name,
    required this.nameLatin,
    required this.numberOfAyah,
    required this.suratNameTranslation,
    required this.startAyat,
    required this.startPage,
    required this.startPageID,
  });

  String number;
  String name;
  String nameLatin;
  String numberOfAyah;
  String suratNameTranslation;
  String startAyat;
  String startPage;
  int startPageID;

  int get startPageToInt => int.parse(startPage);
  int get startAyatToInt => int.parse(startAyat);
  int get numberToInt => int.parse(number);

  factory SuratByJuz.fromJson(Map<String, dynamic> json) => SuratByJuz(
        number: json["number"],
        name: json["name"],
        nameLatin: json["name_latin"],
        numberOfAyah: json["number_of_ayah"],
        suratNameTranslation: json["surat_name_translation"],
        startAyat: json["start_ayat"],
        startPage: json["start_page"],
        startPageID: json["start_ayat_id"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "name_latin": nameLatin,
        "number_of_ayah": numberOfAyah,
        "surat_name_translation": suratNameTranslation,
        "start_ayat": startAyat,
        "start_page": startPage,
        "start_ayat_id": startPageID,
      };
}
