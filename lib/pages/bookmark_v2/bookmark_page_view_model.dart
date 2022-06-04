import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbBookmarks.dart';
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

  List<Bookmarks> listBookmark = [];
  late DbBookmarks db;

  @override
  initViewModel() {
    db = DbBookmarks();
    getAllBookmark();
  }

  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  Future<void> getAllBookmark() async {
    var bookmarkFromDb = await db.getAllBookmark();

    listBookmark.clear();

    bookmarkFromDb!.forEach((bookmark) {
      listBookmark.add(Bookmarks.fromMap(bookmark));
    });


    state = state.copyWith();
  }

  // Future<void> deleteBookmark(suratID, ayatID, int position) async {
  //   await db.deleteBookmark(suratID, ayatID);
  //   listBookmark.removeAt(position);
  //   state = state.copyWith();
  // }
}