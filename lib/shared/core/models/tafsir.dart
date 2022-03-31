import 'dart:convert';

class Tafsir {
    Tafsir({
        required this.text,
    });

    List<String> text;

    factory Tafsir.fromJson(Map<String, dynamic> json) => Tafsir(
        text: List<String>.from(json["text"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "text": List<dynamic>.from(text.map((x) => x)),
    };
}

Tafsir tafsirFromJson(String str) => Tafsir.fromJson(json.decode(str));

String tafsirToJson(Tafsir data) => json.encode(data.toJson());