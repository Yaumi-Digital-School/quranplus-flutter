import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:uuid/uuid.dart';

class AddDailyProgressManualState {
  bool isLoading = true;
  bool? isError = false;
  bool? isSuccessSubmit = false;
  HabitDailySummary currentProgress;
  List<HabitProgress> progressHistory;

  AddDailyProgressManualState({
    required this.currentProgress,
    required this.progressHistory,
    required this.isLoading,
    this.isError,
    this.isSuccessSubmit,
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

class AddDailyProgressManualStateNotifier
    extends BaseStateNotifier<AddDailyProgressManualState> {
  AddDailyProgressManualStateNotifier({
    required HabitDailySummary habitDailySummary,
  })  : _habitDailySummary = habitDailySummary,
        super(AddDailyProgressManualState(
          currentProgress: habitDailySummary,
          progressHistory: [],
          isLoading: true,
        ));
  late DbLocal db;
  final HabitDailySummary _habitDailySummary;

  @override
  Future<void> initStateNotifier() async {
    try {
      state = state.copyWith(isLoading: true);
      db = DbLocal();
      List<HabitProgress> list = [];
      if (_habitDailySummary.id != null) {
        list = await db.getProgressHistory(_habitDailySummary.id!);
      }
      state = state.copyWith(
        isLoading: false,
        isError: false,
        progressHistory: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
      );
    }
  }

  Future<void> addDailyProgressManual(int totalPages) async {
    try {
      state = state.copyWith(
        isLoading: true,
      );
      final currentDay = DateTime.now();

      late int id;

      if (_habitDailySummary.id != null) {
        id = _habitDailySummary.id!;
        await db.updateHabitDailySummary(
          id: id,
          date: currentDay,
          target: _habitDailySummary.target,
          totalPages: totalPages + _habitDailySummary.totalPages,
        );
      }
      if (_habitDailySummary.id == null) {
        id = await db.insertHabitDailySummary(
          date: currentDay,
          target: _habitDailySummary.target,
          totalPages: totalPages,
        );
      }
      var uuid = const Uuid();
      var v1 = uuid.v1();

      await db.insertProgressHistory(
        date: currentDay,
        habitDailySummaryId: id,
        type: HabitProgressType.manual,
        uuid: v1,
        pages: totalPages,
        description: "$totalPages Pages",
      );

      state = state.copyWith(
        isLoading: false,
        isSuccessSubmit: true,
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
      );
    }
  }
}
