import 'dart:convert';

import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class Quran {
    List<Surat> surat;

    Quran({
        required this.surat,
    });
    
    factory Quran.fromJson(Map<String, dynamic> json) => Quran(
        surat: List<Surat>.from(json["surat"].map((x) => Surat.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "surat": List<dynamic>.from(surat.map((x) => x.toJson())),
    };
}

Quran quranFromJson(String str) => Quran.fromJson(json.decode(str));

String quranToJson(Quran data) => json.encode(data.toJson());