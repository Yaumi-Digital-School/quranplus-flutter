import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_sync.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:retrofit/retrofit.dart';

class HabitDailySummaryService {
  HabitDailySummaryService({
    required this.sharedPreferenceService,
    required HabitApi habitApi,
  }) : _habitApi = habitApi;

  final SharedPreferenceService sharedPreferenceService;
  final DbLocal _db = DbLocal();
  final HabitApi _habitApi;

  Future<HabitDailySummary> getCurrentDayHabitDailySummaryListLocal() async {
    final HabitDailySummary result = await _db.getCurrentDayHabitDailySummary();

    return result;
  }

  Future<HabitSyncRequest> _getLocalDataRequest() async {
    final resultHabitDailySummaries =
        await _db.getLocalDbToSync(sharedPreferenceService);
    final lastSync = sharedPreferenceService.getLastSync();

    return HabitSyncRequest(
      dailySummaries: resultHabitDailySummaries,
      lastSync: lastSync.isEmpty ? null : lastSync,
    );
  }

  Future<void> syncHabit({
    ConnectivityResult? connectivityResult,
  }) async {
    connectivityResult ??= await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    try {
      final HabitSyncRequest request = await _getLocalDataRequest();
      final HttpResponse<List<HabitSyncResponseItem>> response =
          await _habitApi.syncHabit(
        request: request,
      );

      if (response.response.statusCode != 200) {
        return;
      }

      sharedPreferenceService.setLastSync(DateTime.now());

      if (response.data.isEmpty) {
        return;
      }

      await _db.upsertHabitDailySummaryOnSync(
        response: response.data,
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
