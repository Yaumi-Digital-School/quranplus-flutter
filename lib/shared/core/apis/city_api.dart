import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import 'model/city.dart';

part 'city_api.g.dart';

@RestApi()
abstract class CityApi {
  factory CityApi(Dio dio, {String baseUrl}) = _CityApi;

  @GET('/api/prayer_times/city')
  Future<HttpResponse<List<CityResponse>>> getUserSummary({
    @Query('q') required String keyword,
  });
}
