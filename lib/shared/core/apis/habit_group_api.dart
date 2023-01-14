import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:retrofit/retrofit.dart';

part 'habit_group_api.g.dart';

@RestApi()
abstract class HabitGroupApi {
  factory HabitGroupApi(Dio dio, {String baseUrl}) = _HabitGroupApi;

  @GET('/api/habit/group')
  Future<HttpResponse<List<GetHabitGroupsResponse>>> getAllGroups({
    @Queries() required GetHabitGroupsParam param,
  });

  @POST('/api/habit/group/create')
  Future<HttpResponse<CreateHabitGroupResponse>> createGroup({
    @Body() required CreateHabitGroupRequest request,
  });
}
