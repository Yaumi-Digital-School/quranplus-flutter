import 'dart:convert';

class Surat {
    String number;
    String name;
    String nameLatin;
    String slug;
    String numberOfAyah;
    String translation;

    Surat({
        required this.number,
        required this.name,
        required this.nameLatin,
        required this.slug,
        required this.numberOfAyah,
        required this.translation
    });

    factory Surat.fromJson(Map<String, dynamic> json) => Surat(
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

class Surats {
    Surats({
        required this.surats,
    });

    List<Surat> surats;

    factory Surats.fromJson(Map<String, dynamic> json) => Surats(
      surats: List<Surat>.from(
        json['surat'].map((surat) => Surat.fromJson(surat))
      )
        // surat: Map.from(json["surat"]).map((k, v) => MapEntry<String, SuratValue>(k, SuratValue.fromJson(v))),
    );

    Map<String, dynamic> toJson() => {
        "surat": List<dynamic>.from(surats.map((surat) => surat.toJson()))
    };
}

Surats suratsFromJson(String str) => Surats.fromJson(json.decode(str));

// String suratToJson(Surat data) => json.encode(data.toJson());
