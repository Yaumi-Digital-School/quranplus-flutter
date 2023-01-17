import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:retrofit/retrofit.dart';

part 'habit_group_api.g.dart';

@RestApi()
abstract class HabitGroupApi {
  factory HabitGroupApi(Dio dio, {String baseUrl}) = _HabitGroupApi;

  @GET('/api/habit/group')
  Future<HttpResponse<List<GetHabitGroupsItem>>> getAllGroups({
    @Queries() required GetHabitGroupsParam param,
  });

  @POST('/api/habit/group/{group_id}/rename')
  Future<HttpResponse<bool>> renameGroup({
    @Body() required UpdateHabitGroupRequest request,
    @Path('group_id') required int groupId,
  });

  @POST('/api/habit/group/create')
  Future<HttpResponse<CreateHabitGroupResponse>> createGroup({
    @Body() required CreateHabitGroupRequest request,
  });

  @GET('/api/habit/group/{group_id}/completions')
  Future<HttpResponse<List<GetHabitGroupCompletionsItemResponse>>>
      getHabitGroupCompletions({
    @Path('group_id') required int groupId,
    @Queries() required GetHabitGroupCompletionsParam param,
  });

  @GET('/api/habit/group/{group_id}/members/summaries')
  Future<HttpResponse<List<GetHabitGroupMemberPersonalItemResponse>>>
      getHabitGroupMemberSummaries({
    @Path('group_id') required int groupId,
    @Queries() required GetHabitGroupMemberSummariesParam param,
  });

  @POST('/api/habit/group/{group_id}/join')
  Future<HttpResponse<bool>> joinGroup({
    @Path('group_id') required int groupId,
    @Body() required JoinHabitGroupRequest request,
  });

  @POST('/api/habit/group/{group_id}/leave/')
  Future<HttpResponse<bool>> leaveGroup({
    @Path('group_id') required int groupId,
    @Body() required LeaveHabitGroupRequest request,
  });
}
