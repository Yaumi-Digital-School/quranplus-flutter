import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class ChangeDailyTargetState {
  bool isLoading;
  bool isError;
  bool isSuccessSubmit;
  HabitDailySummary currentProgress;
  String targetType;

  ChangeDailyTargetState({
    required this.currentProgress,
    this.isLoading = true,
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

class ChangeDailyTargetStateNotifier
    extends BaseStateNotifier<ChangeDailyTargetState> {
  ChangeDailyTargetStateNotifier({
    required HabitDailySummary habitDailySummary,
  })  : _habitDailySummary = habitDailySummary,
        super(ChangeDailyTargetState(
          currentProgress: habitDailySummary,
        ));
  late DbLocal db;
  final HabitDailySummary _habitDailySummary;

  @override
  Future<void> initStateNotifier() async {
    try {
      state = state.copyWith(isLoading: true);
      db = DbLocal();
      state = state.copyWith(
        isLoading: false,
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
      );
    }
  }

  void changeTargetType(String type) {
    state = state.copyWith(targetType: type);
  }

  Future<void> changeDailyTarget(int target, String type) async {
    try {
      state = state.copyWith(
        isLoading: true,
      );

      final totalPagesTarget = type == "Juz" ? 20 * target : target;

      final currentDay = DateTime.now();

      if (_habitDailySummary.id != null) {
        await db.updateHabitDailySummary(
          id: _habitDailySummary.id!,
          date: currentDay,
          target: totalPagesTarget,
          totalPages: _habitDailySummary.totalPages,
        );
      }
      if (_habitDailySummary.id == null) {
        await db.insertHabitDailySummary(
          date: currentDay,
          target: totalPagesTarget,
          totalPages: _habitDailySummary.totalPages,
        );
      }

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
