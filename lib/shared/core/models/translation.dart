import 'dart:convert';

Translation translationFromJson(String str) =>
    Translation.fromJson(json.decode(str));

String translationToJson(Translation data) => json.encode(data.toJson());

class Translation {
  Translation({
    required this.translations,
  });

  List<TranslationElement> translations;

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
        translations: List<TranslationElement>.from(
            json["translations"].map((x) => TranslationElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "translations": List<dynamic>.from(translations.map((x) => x.toJson())),
      };
}

class TranslationElement {
  String name;
  Map<String, String> text;

  TranslationElement({
    required this.name,
    required this.text,
  });

  factory TranslationElement.fromJson(Map<String, dynamic> json) =>
      TranslationElement(
        name: json["name"],
        text: Map.from(json["text"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "text": Map.from(text).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
