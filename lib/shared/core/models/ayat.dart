import 'dart:convert';

class Ayat {
  List<String> text;

  Ayat({
    required this.text,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) => Ayat(
        text: List<String>.from(json["text"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "text": List<dynamic>.from(text.map((x) => x)),
      };
}

Ayat ayatFromJson(String str) => Ayat.fromJson(json.decode(str));

String ayatToJson(Ayat data) => json.encode(data.toJson());
