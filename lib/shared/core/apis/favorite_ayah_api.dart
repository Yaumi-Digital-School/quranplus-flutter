import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:retrofit/retrofit.dart';

part 'favorite_ayah_api.g.dart';

@RestApi()
abstract class FavoriteAyahApi {
  factory FavoriteAyahApi(Dio dio, {String baseUrl}) = _FavoriteAyahApi;

  @POST('/api/favorite')
  Future<HttpResponse<ToggleFavoriteAyahResponse>> toggleFavoriteAyah({
    @Body() required FavoriteAyahs request,
  });

  @GET('/api/favorite')
  Future<HttpResponse<List<GetFavoriteAyahListItemResponse>>>
      getFavoriteAyahs();

  @PUT('/api/favorite')
  Future<HttpResponse<MergeFavoriteAyahResponse>> mergeFavoriteAyahs({
    @Body() required List<FavoriteAyahs> request,
  });
}
