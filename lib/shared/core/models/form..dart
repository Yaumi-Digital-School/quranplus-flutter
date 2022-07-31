import 'dart:convert';

List<FormLink> formLinkFromJson(String str) =>
    List<FormLink>.from(json.decode(str).map((x) => FormLink.fromJson(x)));

String formLinkToJson(List<FormLink> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FormLink {
  FormLink({
    this.id,
    this.link,
    this.description,
  });

  int? id;
  String? link;
  String? description;

  factory FormLink.fromJson(Map<String, dynamic> json) => FormLink(
        id: json["id"],
        link: json["link"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "link": link,
        "description": description,
      };
}
