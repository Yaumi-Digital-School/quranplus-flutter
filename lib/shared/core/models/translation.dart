import 'dart:convert';

class Translation {
    List<String> text;

    Translation({
        required this.text,
    });

    factory Translation.fromJson(Map<String, dynamic> json) => Translation(
        text: List<String>.from(json["text"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "text": List<dynamic>.from(text.map((x) => x)),
    };
}

Translation translationFromJson(String str) => Translation.fromJson(json.decode(str));

String translationToJson(Translation data) => json.encode(data.toJson());