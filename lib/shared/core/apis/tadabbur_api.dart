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
}
