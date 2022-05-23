import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/core/view_models/base_view_model.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

class SuratPageState {
  SuratPageState({
    required this.surat,
    this.bookmarks,
  });

  Surat surat;
  Bookmarks? bookmarks;

  SuratPageState copyWith({
    Bookmarks? bookmarks,
  }) {
    return SuratPageState(
      surat: surat,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class SuratPageViewModel extends BaseViewModel<SuratPageState> {
  SuratPageViewModel({
    required this.surat,
    this.bookmarks,
  }) : super(SuratPageState(
          surat: surat,
          bookmarks: bookmarks,
        ));

  Surat surat;
  Bookmarks? bookmarks;
  late DbHelper db;

  @override
  initViewModel() {
    db = DbHelper();
  }

  Future<bool> checkBookmark(suratID, ayatID) async {
    var result = await db.isBookmark(suratID, ayatID);
    if (result == false) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> insertBookmark(suratID, ayatID) async {
    var result = await db.isBookmark(suratID, ayatID);

    if (result == false) {
      await db.saveBookmark(
        Bookmarks(
          suratid: surat.number,
          ayatid: ayatID.toString(),
        ),
      );

      state = state.copyWith();
    }
  }

  //menghapus data Bookmark
  Future<void> deleteBookmark(suratID, ayatID) async {
    await db.deleteBookmark(suratID, ayatID);
    state = state.copyWith();
  }

  onGoBack(context) {
    state = state.copyWith();
    Navigator.pop(context);
  }
}
