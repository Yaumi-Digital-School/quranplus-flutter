import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbBookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class BookmarkPageState {
  BookmarkPageState({
    this.listBookmarks,
  });

  List<Bookmarks>? listBookmarks;

  BookmarkPageState copyWith({
    List<Bookmarks>? listBookmarks,
  }) {
    return BookmarkPageState(
      listBookmarks: listBookmarks ?? this.listBookmarks,
    );
  }
}

class BookmarkPageStateNotifier extends BaseStateNotifier<BookmarkPageState> {
  BookmarkPageStateNotifier({
    required BookmarkApi bookmarkApi,
    required bool isLoggedIn,
  })  : _bookmarkApi = bookmarkApi,
        _isLoggedIn = isLoggedIn,
        super(BookmarkPageState());

  late DbBookmarks db;
  final BookmarkApi _bookmarkApi;
  final bool _isLoggedIn;
  late ConnectivityResult _connectivityResult;

  @override
  Future<void> initStateNotifier({
    ConnectivityResult? connectivityResult,
  }) async {
    _connectivityResult = connectivityResult ?? ConnectivityResult.none;

    db = DbBookmarks();
    await _getBookmarkFromLocal();
  }

  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  Future<void> _getBookmarkFromLocal() async {
    var bookmarkFromDb = await db.getAllBookmark();
    List<Bookmarks> _listBookmark = [];

    _listBookmark.clear();

    bookmarkFromDb!.forEach((bookmark) {
      _listBookmark.add(Bookmarks.fromMap(bookmark));
    });

    state = state.copyWith(listBookmarks: _listBookmark);
  }

  Future<void> _getBookmarkList() async {
    List<Bookmarks>? _listBookmark;

    HttpResponse<GetBookmarkListResponse> response =
        await _bookmarkApi.getBookmarkList();

    if (response.response.statusCode == 200) {
      _listBookmark = response.data.data;
    }

    state = state.copyWith(listBookmarks: _listBookmark);
  }

  onGoBack(context) {
    Navigator.pop(context);
    state = state.copyWith();
  }
}
