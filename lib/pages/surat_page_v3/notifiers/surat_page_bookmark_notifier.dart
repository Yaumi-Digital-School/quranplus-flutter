import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_bookmark_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/bookmarks_service.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'surat_page_bookmark_notifier.g.dart';

@riverpod
class SuratPageBookmarkNotifier extends _$SuratPageBookmarkNotifier {
  final DbLocal _db = DbLocal();
  final List<int> _bookmarkList = <int>[];
  final List<int> _favoriteAyahList = <int>[];

  BookmarkApi get _bookmarkApi => ref.read(bookmarkApiProvider);
  BookmarksService get _bookmarksService => ref.read(bookmarksService);
  AuthenticationService get _authService => ref.read(authenticationService);

  bool get _isLoggedIn => _authService.isLoggedIn;

  @override
  SuratPageBookmarkState build() => const SuratPageBookmarkState();

  Future<void> load() async {
    await Future.wait([
      _loadBookmarks(),
      _loadFavorites(),
    ]);
  }

  Future<void> _loadBookmarks() async {
    var result = await _db.getBookmarks();
    for (var bookmark in result!) {
      _bookmarkList.add(Bookmarks.fromMap(bookmark).page);
    }
  }

  Future<void> _loadFavorites() async {
    List<FavoriteAyahs> result = await _db.getAllFavoriteAyahs();
    for (FavoriteAyahs favorite in result) {
      _favoriteAyahList.add(favorite.ayahHashCode);
    }
  }

  void checkIsBookmarkExists(int page) {
    state = state.copyWith(
      visibleIconBookmark: _bookmarkList.contains(page),
    );
  }

  bool isAyahFavorited(int ayahID) => _favoriteAyahList.contains(ayahID);

  Future<void> insertBookmark(
    String surahName,
    int page,
    ConnectivityStatus connectivityStatus,
  ) async {
    await _db.saveBookmark(Bookmarks(surahName: surahName, page: page));

    if (connectivityStatus == ConnectivityStatus.isConnected && _isLoggedIn) {
      _toggleBookmark(surahName: surahName, page: page);
    }

    if (connectivityStatus == ConnectivityStatus.isDisconnected) {
      _bookmarksService.setIsMerged(false);
    }

    _bookmarkList.add(page);
    state = state.copyWith(
      visibleIconBookmark: true,
      isBookmarkChanged: true,
    );
  }

  Future<void> deleteBookmark(
    int page,
    ConnectivityStatus connectivityStatus,
  ) async {
    if (connectivityStatus == ConnectivityStatus.isConnected && _isLoggedIn) {
      await _toggleBookmark(page: page);
    }
    await _db.deleteBookmark(page);
    _bookmarkList.removeWhere((p) => p == page);
    state = state.copyWith(
      visibleIconBookmark: false,
      isBookmarkChanged: true,
    );
  }

  Future<void> _toggleBookmark({required int page, String? surahName}) async {
    try {
      // ignore: unused_local_variable
      Future<HttpResponse<CreateBookmarkResponse>> _ =
          _bookmarkApi.createBookmark(
        request: CreateBookmarkRequest(
          surahId: surahNameToSurahNumberMap[surahName],
          page: page,
        ),
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _toggleBookmark() method',
      );
    }
  }

  Future<void> toggleFavoriteAyah({
    required int surahNumber,
    required int ayahNumber,
    required int ayahID,
    required int page,
  }) async {
    if (isAyahFavorited(ayahID)) {
      await _deleteFavoriteAyah(ayahID);
    } else {
      await _insertFavoriteAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        ayahID: ayahID,
        page: page,
      );
    }
    state = state.copyWith(isFavoriteAyahChanged: true);
  }

  Future<void> _deleteFavoriteAyah(int ayahID) async {
    await _db.deleteFavoriteAyahs(ayahID);
    _favoriteAyahList.removeWhere((item) => item == ayahID);
  }

  Future<void> _insertFavoriteAyah({
    required int surahNumber,
    required int ayahNumber,
    required int ayahID,
    required int page,
  }) async {
    await _db.saveFavoriteAyahs(FavoriteAyahs(
      surahId: surahNumber,
      page: page,
      ayahSurah: ayahNumber,
      ayahHashCode: ayahID,
    ));
    _favoriteAyahList.add(ayahID);
  }
}
