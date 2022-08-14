import 'dart:convert';

FormLink formLinkFromJson(String str) => FormLink.fromJson(json.decode(str));

String formLinkToJson(FormLink data) => json.encode(data.toJson());

class FormLink {
  FormLink({
    this.name,
    this.url,
  });

  String? name;
  String? url;

  factory FormLink.fromJson(Map<String, dynamic> json) => FormLink(
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
      };
}
