import 'dart:convert';

Surat suratFromJson(String str) => Surat.fromJson(json.decode(str));

String suratToJson(Surat data) => json.encode(data.toJson());

class Surat {
    Surat({
        required this.surat,
    });

    Map<String, SuratValue> surat;

    factory Surat.fromJson(Map<String, dynamic> json) => Surat(
        surat: Map.from(json["surat"]).map((k, v) => MapEntry<String, SuratValue>(k, SuratValue.fromJson(v))),
    );

    Map<String, dynamic> toJson() => {
        "surat": Map.from(surat).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    };
}

class SuratValue {
    String number;
    String name;
    String nameLatin;
    String slug;
    String numberOfAyah;
    String translation;

    SuratValue({
        required this.number,
        required this.name,
        required this.nameLatin,
        required this.slug,
        required this.numberOfAyah,
        required this.translation,
    });

    factory SuratValue.fromJson(Map<String, dynamic> json) => SuratValue(
        number: json["number"],
        name: json["name"],
        nameLatin: json["name_latin"],
        slug: json["slug"],
        numberOfAyah: json["number_of_ayah"],
        translation: json["translation"],
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "name_latin": nameLatin,
        "slug": slug,
        "number_of_ayah": numberOfAyah,
        "translation": translation,
    };
}
