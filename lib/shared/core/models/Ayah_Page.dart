import 'dart:convert';

AyahPage AyahPageFromJson(String str) => AyahPage.fromJson(json.decode(str));

String AyahPageToJson(AyahPage data) => json.encode(data.toJson());

class AyahPage {
  AyahPage({
    required this.surah,
  });

  List<Map<String, List<String>>> surah;

  factory AyahPage.fromJson(Map<String, dynamic> json) => AyahPage(
        surah: List<Map<String, List<String>>>.from(json["Surah"].map((x) =>
            Map.from(x).map((k, v) => MapEntry<String, List<String>>(
                k, List<String>.from(v.map((x) => x)))))),
      );

  Map<String, dynamic> toJson() => {
        "Surah": List<dynamic>.from(surah.map((x) => Map.from(x).map((k, v) =>
            MapEntry<String, dynamic>(
                k, List<dynamic>.from(v.map((x) => x)))))),
      };
}
