// ignore_for_file: file_names, unnecessary_this, prefer_collection_literals

import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class Bookmarks {
  Bookmarks({
    this.id,
    required this.namaSurat,
    this.juz,
    required this.page,
  });

  int? id;
  late String namaSurat;
  int? juz;
  late int page;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }
    map['namaSurat'] = namaSurat;
    map['juz'] = juz;
    map['page'] = page;

    return map;
  }

  Bookmarks.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.namaSurat = map['namaSurat'];
    this.juz = map['juz'];
    this.page = map['page'];
  }
}
