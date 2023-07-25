import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'audio_api.g.dart';

@RestApi()
abstract class AudioApi {
  factory AudioApi(Dio dio, {String baseUrl}) = _AudioApi;

  @GET('/api/recitations/{reciter_id}/by_ayah/{surah_id}/{ayah_number}')
  Future<HttpResponse> getAudioForSpecificReciterAndAyah({
    @Path('reciter_id') required int reciterId,
    @Path('surah_id') required int surahId,
    @Path('ayah_number') required int ayahNumber,
  });
}
