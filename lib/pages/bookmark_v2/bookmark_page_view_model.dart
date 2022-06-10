import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbBookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/core/view_models/base_view_model.dart';

class BookmarkPageState {
  BookmarkPageState({
    this.listBookmarks,
  });

  List<Bookmarks>? listBookmarks;

  BookmarkPageState copyWith({
      List<Bookmarks>? listBookmarks,    
  }) {
    return BookmarkPageState(
      listBookmarks: listBookmarks ?? this.listBookmarks
    );
  }
}
class BookmarkPageViewModel extends BaseViewModel<BookmarkPageState> {
  BookmarkPageViewModel() : super(BookmarkPageState());

  late DbBookmarks db;

  @override
  Future<void> initViewModel() async {
    db = DbBookmarks();
    await _getAllBookmark();
  }

  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  Future<void> _getAllBookmark() async {
    var bookmarkFromDb = await db.getAllBookmark();
    List<Bookmarks> _listBookmark = [];

    _listBookmark.clear();

    bookmarkFromDb!.forEach((bookmark) {
      _listBookmark.add(Bookmarks.fromMap(bookmark));
    });


    state = state.copyWith(listBookmarks: _listBookmark);
  }

  onGoBack(context) {
    Navigator.pop(context);
    state = state.copyWith();
  }

  // Future<void> deleteBookmark(suratID, ayatID, int position) async {
  //   await db.deleteBookmark(suratID, ayatID);
  //   listBookmark.removeAt(position);
  //   state = state.copyWith();
  // }
}