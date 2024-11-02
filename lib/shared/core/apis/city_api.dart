import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import 'model/city.dart';

part 'city_api.g.dart';

@RestApi()
abstract class CityApi {
  factory CityApi(Dio dio, {String baseUrl}) = _CityApi;

  @GET('/api/location/search_city')
  Future<HttpResponse<List<CityResponse>>> getCities({
    @Query('q') required String keyword,
  });

  @GET('/api/location/lookup_city')
  Future<HttpResponse<CityResponse>> getCityDetail({
    @Query('id') required String id,
  });
}
