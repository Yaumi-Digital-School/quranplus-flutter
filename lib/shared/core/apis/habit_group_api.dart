import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group_response.dart';
import 'package:retrofit/retrofit.dart';

part 'habit_group_api.g.dart';

@RestApi()
abstract class HabitGroupApi {
  factory HabitGroupApi(Dio dio, {String baseUrl}) = _HabitGroupApi;

  @POST('/api/habit/group')
  Future<HttpResponse<List<GetHabitGroupsResponse>>> getAllGroups();
}
