import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:retrofit/retrofit.dart';

class BookmarksService {
  BookmarksService({
    required BookmarkApi bookmarkApi,
  }) : _bookmarkApi = bookmarkApi;

  bool _isMerged = false;
  final DbLocal _db = DbLocal();
  final BookmarkApi _bookmarkApi;

  bool get isMerged => _isMerged;
  void setIsMerged(bool value) => _isMerged = value;

  Future<List<Bookmarks>> getBookmarkFromLocal() async {
    var bookmarkFromDb = await _db.getAllBookmark();
    List<Bookmarks> _listBookmark = [];

    _listBookmark.clear();

    for (var bookmark in bookmarkFromDb!) {
      _listBookmark.add(Bookmarks.fromMap(bookmark));
    }

    return _listBookmark;
  }

  Future<List<Bookmarks>> _getBookmarkList() async {
    List<Bookmarks> _listBookmark = <Bookmarks>[];

    HttpResponse<GetBookmarkListResponse> response =
        await _bookmarkApi.getBookmarkList();

    if (response.response.statusCode == 200 && response.data.data != null) {
      _listBookmark = response.data.data!;
    }

    return _listBookmark;
  }

  Future<void> clearBookmarkAndMergeFromServer() async {
    await _db.clearTableBookmarks();
    final List<Bookmarks> _serverBookmarks = await _getBookmarkList();
    await _db.bulkCreateBookmarks(_serverBookmarks);
    setIsMerged(true);
  }

  Future<void> mergeBookmarkToServer() async {
    if (_isMerged) {
      return;
    }

    final List<Bookmarks> _localBookmarks = await getBookmarkFromLocal();
    if (_localBookmarks.isEmpty) {
      final List<Bookmarks> _serverBookmarks = await _getBookmarkList();
      await _db.bulkCreateBookmarks(_serverBookmarks);
      setIsMerged(true);

      return;
    }

    final List<MergeBookmarkRequest> request = <MergeBookmarkRequest>[];
    for (Bookmarks bookmark in _localBookmarks) {
      request.add(
        MergeBookmarkRequest(
          surahID: surahNameToSurahNumberMap[bookmark.surahName] ?? 0,
          createdAt: bookmark.createdAt ?? '',
          page: bookmark.page,
        ),
      );
    }

    final HttpResponse<GetBookmarkListResponse> _ =
        await _bookmarkApi.mergeBookmarks(
      request: request,
    );

    final List<Bookmarks> _serverBookmarks = await _getBookmarkList();
    await _db.clearTableBookmarks();
    await _db.bulkCreateBookmarks(_serverBookmarks);
    setIsMerged(true);
  }
}
