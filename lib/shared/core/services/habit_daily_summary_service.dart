import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
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
    ConnectivityStatus? connectivityStatus,
  }) async {
    try {
      final HabitSyncRequest request = await _getLocalDataRequest();

      if (connectivityStatus == ConnectivityStatus.isDisconnected) {
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
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on syncHabit() method',
      );
      print(error);
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
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on isNeedSync() method',
      );

      return false;
    }
  }
}
