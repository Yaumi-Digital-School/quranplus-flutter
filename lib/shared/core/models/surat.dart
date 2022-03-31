import 'dart:convert';

import 'package:qurantafsir_flutter/shared/core/models/ayat.dart';
import 'package:qurantafsir_flutter/shared/core/models/tafsir.dart';
import 'package:qurantafsir_flutter/shared/core/models/translation.dart';

class Surat {
    Surat({
        required this.number,
        required this.name,
        required this.nameLatin,
        required this.slug,
        required this.numberOfAyah,
        required this.suratNameTranslation,
        required this.ayats,
        required this.translations,
        required this.tafsir,
    });

    String number;
    String name;
    String nameLatin;
    String slug;
    String numberOfAyah;
    String suratNameTranslation;
    Ayat ayats;
    Translation translations;
    Tafsir tafsir;

    factory Surat.fromJson(Map<String, dynamic> json) => Surat(
        number: json["number"],
        name: json["name"],
        nameLatin: json["name_latin"],
        slug: json["slug"],
        numberOfAyah: json["number_of_ayah"],
        suratNameTranslation: json["surat_name_translation"],
        ayats: Ayat.fromJson(json["ayats"]),
        translations: Translation.fromJson(json["translations"]),
        tafsir: Tafsir.fromJson(json["tafsir"]),
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "name_latin": nameLatin,
        "slug": slug,
        "number_of_ayah": numberOfAyah,
        "surat_name_translation": suratNameTranslation,
        "ayats": ayats.toJson(),
        "translations": translations.toJson(),
        "tafsir": tafsir.toJson(),
    };
}

Surat suratFromJson(String str) => Surat.fromJson(json.decode(str));

String suratToJson(Surat data) => json.encode(data.toJson());
