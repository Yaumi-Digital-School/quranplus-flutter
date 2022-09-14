import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/services/bookmarks_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

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
    required BookmarksService bookmarksService,
    required bool isLoggedIn,
  })  : _isLoggedIn = isLoggedIn,
        _bookmarksService = bookmarksService,
        super(BookmarkPageState());

  final BookmarksService _bookmarksService;
  final bool _isLoggedIn;
  List<Bookmarks>? _localBookmarks;
  late ConnectivityResult _connectivityResult;

  @override
  Future<void> initStateNotifier({
    ConnectivityResult? connectivityResult,
  }) async {
    _connectivityResult = connectivityResult ?? ConnectivityResult.none;

    if (_isLoggedIn && _connectivityResult != ConnectivityResult.none) {
      await _bookmarksService.mergeBookmarkToServer();
    }

    _localBookmarks = await _bookmarksService.getBookmarkFromLocal();
    state = state.copyWith(listBookmarks: _localBookmarks);
  }

  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  onGoBack(context) {
    Navigator.pop(context);
    state = state.copyWith();
  }
}
