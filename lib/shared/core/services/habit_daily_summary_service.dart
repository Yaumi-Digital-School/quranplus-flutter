import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_sync.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:retrofit/retrofit.dart';

const threeHourInSeconds = 10800;

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
      lastSync: lastSync,
    );
  }

  Future<void> syncHabit({
    ConnectivityResult? connectivityResult,
  }) async {
    connectivityResult ??= await Connectivity().checkConnectivity();

    try {
      final HabitSyncRequest request = await _getLocalDataRequest();

      if (connectivityResult == ConnectivityResult.none) {
        final habitNeedToSyncTimer =
            sharedPreferenceService.getHabitNeedToSyncTimer();
        if (habitNeedToSyncTimer == "" && request.dailySummaries.isNotEmpty) {
          await sharedPreferenceService.setHabitNeedToSyncTimer(DateTime.now());
        }

        return;
      }

      final HttpResponse<List<HabitSyncResponseItem>> response =
          await _habitApi.syncHabit(
        request: request,
      );

      if (response.response.statusCode != 200) {
        return;
      }

      await sharedPreferenceService.setHabitNeedToSyncTimer(null);

      await sharedPreferenceService.setLastSync(DateTime.now());

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

  bool isNeedSync() {
    try {
      final habitNeedToSync = sharedPreferenceService.getHabitNeedToSyncTimer();
      if (habitNeedToSync == "") return false;

      final currentTime = DateTime.now();
      final habitNeedToSyncTime = DateTime.parse(habitNeedToSync);
      final differenceInSeconds =
          currentTime.difference(habitNeedToSyncTime).inSeconds;

      if (differenceInSeconds > threeHourInSeconds) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
