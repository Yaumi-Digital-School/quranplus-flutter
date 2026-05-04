import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_progress.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'add_daily_progress_manual_state_notifier.g.dart';

class AddDailyProgressManualState {
  bool isLoading;
  bool? isError;
  bool? isSuccessSubmit;
  HabitDailySummary? currentProgress;
  List<HabitProgress> progressHistory;

  AddDailyProgressManualState({
    this.currentProgress,
    this.progressHistory = const [],
    this.isLoading = true,
    this.isError = false,
    this.isSuccessSubmit = false,
  });

  AddDailyProgressManualState copyWith({
    bool? isLoading,
    bool? isError,
    HabitDailySummary? currentProgress,
    List<HabitProgress>? progressHistory,
    bool? isSuccessSubmit,
  }) {
    return AddDailyProgressManualState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      currentProgress: currentProgress ?? this.currentProgress,
      progressHistory: progressHistory ?? this.progressHistory,
      isSuccessSubmit: isSuccessSubmit ?? this.isSuccessSubmit,
    );
  }
}

@riverpod
class AddDailyProgressManualNotifier
    extends _$AddDailyProgressManualNotifier {
  final DbLocal _db = DbLocal();

  @override
  AddDailyProgressManualState build() => AddDailyProgressManualState();

  Future<void> init(HabitDailySummary habitDailySummary) async {
    try {
      state = state.copyWith(isLoading: true, currentProgress: habitDailySummary);
      List<HabitProgress> list = [];
      if (habitDailySummary.id != null) {
        list = await _db.getProgressHistory(habitDailySummary.id!);
      }
      state = state.copyWith(
        isLoading: false,
        isError: false,
        progressHistory: list,
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on init() method in daily progress manual',
      );
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> addDailyProgressManual(int totalPages) async {
    final habitDailySummary = state.currentProgress;
    if (habitDailySummary == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final currentDay = DateTime.now();
      late int id;

      if (habitDailySummary.id != null) {
        id = habitDailySummary.id!;
        await _db.updateHabitDailySummary(
          id: id,
          date: currentDay,
          target: habitDailySummary.target,
          totalPages: totalPages + habitDailySummary.totalPages,
        );
      } else {
        id = await _db.insertHabitDailySummary(
          date: currentDay,
          target: habitDailySummary.target,
          totalPages: totalPages,
        );
      }

      final v1 = const Uuid().v1();
      await _db.insertProgressHistory(
        date: currentDay,
        habitDailySummaryId: id,
        type: HabitProgressType.manual,
        uuid: v1,
        pages: totalPages,
        description: "$totalPages Pages",
      );

      final int newTotalPages = totalPages + habitDailySummary.totalPages;
      if (newTotalPages >= habitDailySummary.target) {
        await cancelAllQuranReminders();
      }

      state = state.copyWith(
        isLoading: false,
        isSuccessSubmit: true,
        isError: false,
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on addDailyProgressManual() method',
      );
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
