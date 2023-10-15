import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
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
    var bookmarkFromDb = await _db.getBookmarks();
    List<Bookmarks> listBookmark = [];

    listBookmark.clear();

    for (var bookmark in bookmarkFromDb!) {
      listBookmark.add(Bookmarks.fromMap(bookmark));
    }

    return listBookmark;
  }

  Future<List<Bookmarks>> _getBookmarkList() async {
    List<Bookmarks> listBookmark = <Bookmarks>[];

    HttpResponse<GetBookmarkListResponse> response =
        await _bookmarkApi.getBookmarkList();

    if (response.response.statusCode == 200 && response.data.data != null) {
      listBookmark = response.data.data!;
    }

    return listBookmark;
  }

  Future<void> clearBookmarkAndMergeFromServer() async {
    await _db.clearTableBookmarks();
    final List<Bookmarks> serverBookmarks = await _getBookmarkList();
    await _db.bulkCreateBookmarks(serverBookmarks);
    setIsMerged(true);
  }

  Future<void> mergeBookmarkToServer() async {
    if (_isMerged) {
      return;
    }

    final List<Bookmarks> localBookmarks = await getBookmarkFromLocal();
    if (localBookmarks.isEmpty) {
      final List<Bookmarks> serverBookmarks = await _getBookmarkList();
      await _db.bulkCreateBookmarks(serverBookmarks);
      setIsMerged(true);

      return;
    }

    final List<MergeBookmarkRequest> request = <MergeBookmarkRequest>[];
    for (Bookmarks bookmark in localBookmarks) {
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

    final List<Bookmarks> serverBookmarks = await _getBookmarkList();
    await _db.clearTableBookmarks();
    await _db.bulkCreateBookmarks(serverBookmarks);
    setIsMerged(true);
  }
}
