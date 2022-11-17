import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/services/bookmarks_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/favorite_ayahs_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class BookmarkPageState {
  BookmarkPageState({
    this.listBookmarks,
    this.listFavoriteAyah,
  });

  List<Bookmarks>? listBookmarks;
  List<FavoriteAyahs>? listFavoriteAyah;

  BookmarkPageState copyWith({
    List<Bookmarks>? listBookmarks,
    List<FavoriteAyahs>? listFavoriteAyah,
  }) {
    return BookmarkPageState(
      listBookmarks: listBookmarks ?? this.listBookmarks,
      listFavoriteAyah: listFavoriteAyah ?? this.listFavoriteAyah,
    );
  }
}

class BookmarkPageStateNotifier extends BaseStateNotifier<BookmarkPageState> {
  BookmarkPageStateNotifier({
    required BookmarksService bookmarksService,
    required FavoriteAyahsService favoriteAyahsService,
    required bool isLoggedIn,
  })  : _isLoggedIn = isLoggedIn,
        _bookmarksService = bookmarksService,
        _favoriteAyahsService = favoriteAyahsService,
        super(BookmarkPageState());

  final BookmarksService _bookmarksService;
  final FavoriteAyahsService _favoriteAyahsService;
  final bool _isLoggedIn;
  List<Bookmarks>? _localBookmarks;
  List<FavoriteAyahs>? _localFavoriteAyahs;
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
    _localFavoriteAyahs =
        await _favoriteAyahsService.getFavoriteAyahListLocal();

    state = state.copyWith(
      listBookmarks: _localBookmarks,
      listFavoriteAyah: _localFavoriteAyahs,
    );
  }

  Future<void> initFavoriteAyahSection({
    ConnectivityResult? connectivityResult,
  }) async {
    _connectivityResult = connectivityResult ?? ConnectivityResult.none;
    // if (_isLoggedIn && _connectivityResult != ConnectivityResult.none) {
    //   await _bookmarksService.mergeBookmarkToServer();
    // }

    _localFavoriteAyahs =
        await _favoriteAyahsService.getFavoriteAyahListLocal();

    state = state.copyWith(
      listFavoriteAyah: _localFavoriteAyahs,
    );
  }

  Future<void> initBookmarkSection({
    ConnectivityResult? connectivityResult,
  }) async {
    _connectivityResult = connectivityResult ?? ConnectivityResult.none;

    if (_isLoggedIn && _connectivityResult != ConnectivityResult.none) {
      await _bookmarksService.mergeBookmarkToServer();
    }

    _localBookmarks = await _bookmarksService.getBookmarkFromLocal();

    state = state.copyWith(
      listBookmarks: _localBookmarks,
    );
  }

  onGoBack(context) {
    Navigator.pop(context);
    state = state.copyWith();
  }
}
