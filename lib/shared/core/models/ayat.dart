import 'dart:convert';

class Ayat {
  List<Ayats> ayats;

  Ayat({
    required this.ayats,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) => Ayat(
        ayats: List<Ayats>.from(json["ayats"].map((x) => Ayats.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ayats": List<dynamic>.from(ayats.map((x) => x.toJson())),
      };
}

class Ayats {
  List<String> text;

  Ayats({
    required this.text,
  });

  factory Ayats.fromJson(Map<String, dynamic> json) => Ayats(
        text: List<String>.from(json["text"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "text": List<dynamic>.from(text.map((x) => x)),
      };
}

Ayat ayatFromJson(String str) => Ayat.fromJson(json.decode(str));

String ayatToJson(Ayat data) => json.encode(data.toJson());
