import 'package:dio/dio.dart';
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
}
