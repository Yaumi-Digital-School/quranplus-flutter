import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:retrofit/retrofit.dart';

part 'bookmark_api.g.dart';

@RestApi()
abstract class BookmarkApi {
  factory BookmarkApi(Dio dio, {String baseUrl}) = _BookmarkApi;

  @POST('/api/bookmark')
  Future<HttpResponse<CreateBookmarkResponse>> createBookmark({
    @Body() required CreateBookmarkRequest request,
  });

  @GET('/api/bookmarks')
  Future<HttpResponse<GetBookmarkListResponse>> getBookmarkList();

  @PUT('/api/bookmarks')
  Future<HttpResponse<GetBookmarkListResponse>> mergeBookmarks({
    @Body() required List<MergeBookmarkRequest> request,
  });
}
