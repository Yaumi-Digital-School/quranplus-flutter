import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';


// final Surat surat;
DbHelper db = DbHelper();
List<Bookmarks> initialDataBookmark = [];
List<Surat> initialDataSurat = [];

Future<String> getJson() {
  return rootBundle.loadString('data/quran.json');
}

Future<void> getAllBookmark() async {
  var bookmarks = await db.getAllBookmark();

  Map<String, dynamic> map = await json.decode(await getJson());
  List<dynamic> surats = map['surat'];

  for(var bookmark in bookmarks!){
    initialDataBookmark.add(Bookmarks.fromMap(bookmark));
  }

  for(var surat in surats){
    for(var bookmark in initialDataBookmark){
      if (surat['number'] == bookmark.suratid){
        initialDataSurat.add(Surat.fromJson(surat));
      }
    }
  }
}

class BookmarkProvider with ChangeNotifier {
  final List<Surat> _bookmark = initialDataSurat;

  List<Surat> get bookmarks => _bookmark;
}