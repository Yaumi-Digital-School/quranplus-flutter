import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/core/view_models/base_view_model.dart';

class BookmarkPageState {
  BookmarkPageState copyWith() {
    return BookmarkPageState();
  }
}
class BookmarkPageViewModel extends BaseViewModel<BookmarkPageState> {
  BookmarkPageViewModel() : super(BookmarkPageState());

  List<Surat> listBookmark = [];
  List<dynamic> listayatID = [];
  late DbHelper db;

  @override
  initViewModel() {
    db = DbHelper();
    getAllBookmark();
  }

  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  Future<void> getAllBookmark() async {
    var bookmarkFromDb = await db.getAllBookmark();

    List<Bookmarks> _bookmarkFromDb = [];
    Map<String, dynamic> map = await json.decode(await getJson());
    List<dynamic> surat = map['surat'];

    listBookmark.clear();

    bookmarkFromDb!.forEach((bookmark) {
      _bookmarkFromDb.add(Bookmarks.fromMap(bookmark));
    });

    surat.forEach((surat) {
      _bookmarkFromDb.forEach((bookmark) {
        if (surat['number'] == bookmark.suratid) {
          listBookmark.add(Surat.fromJson(surat));
          listayatID.add(bookmark.ayatid);
        }
      });
    });

    state = state.copyWith();
  }

  Future<void> deleteBookmark(suratID, ayatID, int position) async {
    await db.deleteBookmark(suratID, ayatID);
    listBookmark.removeAt(position);
    state = state.copyWith();
  }
}