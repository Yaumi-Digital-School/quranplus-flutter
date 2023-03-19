import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:retrofit/retrofit.dart';

part 'tadabbur_api.g.dart';

@RestApi()
abstract class TadabburApi {
  factory TadabburApi(Dio dio, {String baseUrl}) = _TadabburApi;

  @GET('/api/tadabbur/availables')
  Future<HttpResponse<List<GetTadabburSurahListItemResponse>>>
      getAvailableTadabburSurahList();

  @GET('/api/tadabbur/{surah_id}')
  Future<HttpResponse<List<TadabburItemResponse>>> getListTadabburOfSurah({
    @Path('surah_id') required int surahId,
  });

  @GET('/api/tadabbur/content/{tadabbur_id}')
  Future<HttpResponse<TadabburContentResponse>> getTadabburContent({
    @Path('tadabbur_id') required int tadabburId,
  });

  @GET('/api/tadabbur/ayah')
  Future<HttpResponse<dynamic>> getListOfAvailableTadabburAyah();
}
