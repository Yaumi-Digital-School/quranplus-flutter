import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_response.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  @POST('/api/user')
  Future<HttpResponse<UserResponse>> createUser(@Body() User user);

  @GET('/api/my-profile')
  Future<HttpResponse<UserResponse>> getUserProfile(
      @Header("x-access-token") String token);

  @PUT('/api/user')
  Future<HttpResponse<UserResponse>> updateUserProfile(
      @Header("x-access-token") String token, @Body() User user);
}
