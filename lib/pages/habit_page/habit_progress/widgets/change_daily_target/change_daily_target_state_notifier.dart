import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_daily_target_state_notifier.g.dart';

class ChangeDailyTargetState {
  bool isLoading;
  bool isError;
  bool isSuccessSubmit;
  HabitDailySummary? currentProgress;
  String targetType;

  ChangeDailyTargetState({
    this.currentProgress,
    this.isLoading = false,
    this.isError = false,
    this.isSuccessSubmit = false,
    this.targetType = '',
  });

  ChangeDailyTargetState copyWith({
    bool? isLoading,
    bool? isError,
    HabitDailySummary? currentProgress,
    bool? isSuccessSubmit,
    String? targetType,
  }) {
    return ChangeDailyTargetState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      currentProgress: currentProgress ?? this.currentProgress,
      isSuccessSubmit: isSuccessSubmit ?? this.isSuccessSubmit,
      targetType: targetType ?? this.targetType,
    );
  }
}

@riverpod
class ChangeDailyTargetNotifier extends _$ChangeDailyTargetNotifier {
  final DbLocal _db = DbLocal();

  @override
  ChangeDailyTargetState build() => ChangeDailyTargetState();

  void init(HabitDailySummary habitDailySummary) {
    state = state.copyWith(currentProgress: habitDailySummary);
  }

  void changeTargetType(String type) {
    state = state.copyWith(targetType: type);
  }

  Future<void> changeDailyTarget(int target, String type) async {
    final habitDailySummary = state.currentProgress;
    if (habitDailySummary == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final totalPagesTarget = type == "Juz" ? 20 * target : target;
      final currentDay = DateTime.now();

      if (habitDailySummary.id != null) {
        await _db.updateHabitDailySummary(
          id: habitDailySummary.id!,
          date: currentDay,
          target: totalPagesTarget,
          totalPages: habitDailySummary.totalPages,
        );
      } else {
        await _db.insertHabitDailySummary(
          date: currentDay,
          target: totalPagesTarget,
          totalPages: habitDailySummary.totalPages,
        );
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
        reason: 'error on changeDailyTarget() method',
      );
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
