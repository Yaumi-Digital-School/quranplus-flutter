import 'dart:convert';

Tafsir tafsirFromJson(String str) => Tafsir.fromJson(json.decode(str));

String tafsirToJson(Tafsir data) => json.encode(data.toJson());

class Tafsir {
  Map<String, TafsirValue> tafsir;

  Tafsir({
    required this.tafsir,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) => Tafsir(
        tafsir: Map.from(json["tafsir"]).map((k, v) =>
            MapEntry<String, TafsirValue>(k, TafsirValue.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "tafsir": Map.from(tafsir)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class TafsirValue {
  Kemenag kemenag;

  TafsirValue({
    required this.kemenag,
  });

  factory TafsirValue.fromJson(Map<String, dynamic> json) => TafsirValue(
        kemenag: Kemenag.fromJson(json["kemenag"]),
      );

  Map<String, dynamic> toJson() => {
        "kemenag": kemenag.toJson(),
      };
}

class Kemenag {
  Kemenag({
    required this.text,
  });

  Map<String, String> text;

  factory Kemenag.fromJson(Map<String, dynamic> json) => Kemenag(
        text: Map.from(json["text"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "text": Map.from(text).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
