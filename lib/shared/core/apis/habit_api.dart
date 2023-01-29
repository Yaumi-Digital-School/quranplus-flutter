import 'package:dio/dio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_sync.dart';
import 'package:retrofit/retrofit.dart';

part 'habit_api.g.dart';

@RestApi()
abstract class HabitApi {
  factory HabitApi(Dio dio, {String baseUrl}) = _HabitApi;

  @POST('/api/habit/sync')
  Future<HttpResponse<List<HabitSyncResponseItem>>> syncHabit({
    @Body() required HabitSyncRequest request,
  });

  @GET('/api/habit/{userId}/summary/')
  Future<HttpResponse<UserSummaryResponse>> getUserSummary({
    @Path('userId') required int userId,
    @Queries() required UserSummaryRequest param,
  });
}
