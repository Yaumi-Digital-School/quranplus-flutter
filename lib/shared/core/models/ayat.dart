import 'dart:convert';

Ayat ayatFromJson(String str) => Ayat.fromJson(json.decode(str));

String ayatToJson(Ayat data) => json.encode(data.toJson());

class Ayat {
  Map<String, AyatValue> ayats;

  Ayat({
    required this.ayats,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) => Ayat(
        ayats: Map.from(json["ayats"]).map(
            (k, v) => MapEntry<String, AyatValue>(k, AyatValue.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "ayats": Map.from(ayats)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class AyatValue {
  Map<String, String> text;
  Translations translations;

  AyatValue({
    required this.text,
    required this.translations,
  });

  factory AyatValue.fromJson(Map<String, dynamic> json) => AyatValue(
        text: Map.from(json["text"])
            .map((k, v) => MapEntry<String, String>(k, v)),
        translations: Translations.fromJson(json["translations"]),
      );

  Map<String, dynamic> toJson() => {
        "text": Map.from(text).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "translations": translations.toJson(),
      };
}

class Translations {
  Id id;

  Translations({
    required this.id,
  });

  factory Translations.fromJson(Map<String, dynamic> json) => Translations(
        id: Id.fromJson(json["id"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id.toJson(),
      };
}

class Id {
  String name;
  Map<String, String> text;

  Id({
    required this.name,
    required this.text,
  });

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        name: json["name"],
        text: Map.from(json["text"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "text": Map.from(text).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
