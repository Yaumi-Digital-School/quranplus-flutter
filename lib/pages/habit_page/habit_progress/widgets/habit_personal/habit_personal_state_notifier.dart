import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_personal_state_notifier.g.dart';

class HabitPersonalState {
  bool isLoading;
  bool? isError = false;
  String? currentMonth = "";
  HabitDailySummary? currentProgress;
  List<HabitDailySummary>? lastSevenDays = [];
  bool isNeedSync;

  HabitPersonalState({
    this.isLoading = true,
    this.currentMonth,
    this.lastSevenDays,
    this.isError,
    this.currentProgress,
    required this.isNeedSync,
  });

  HabitPersonalState copyWith({
    bool? isLoading,
    String? currentMonth,
    List<HabitDailySummary>? lastSevenDays,
    bool? isError,
    HabitDailySummary? currentProgress,
    bool? isNeedSync,
  }) {
    return HabitPersonalState(
      isLoading: isLoading ?? this.isLoading,
      currentMonth: currentMonth ?? this.currentMonth,
      lastSevenDays: lastSevenDays ?? this.lastSevenDays,
      isError: isError ?? this.isError,
      currentProgress: currentProgress ?? this.currentProgress,
      isNeedSync: isNeedSync ?? this.isNeedSync,
    );
  }
}

@riverpod
class HabitPersonalNotifier extends _$HabitPersonalNotifier {
  final DbLocal _db = DbLocal();

  @override
  HabitPersonalState build() {
    Future.microtask(fetchData);
    return HabitPersonalState(isNeedSync: false);
  }

  Future<void> fetchData() async {
    try {
      state = state.copyWith(isLoading: true);
      final habitDailyService = ref.read(habitDailySummaryService);
      final now = DateTime.now();
      final formattedDate = DateFormat('MMMM yyyy').format(now);
      await habitDailyService.syncHabit();
      final listHabit = await _db.getLastSevenDays(now);
      final currentProgress =
          await habitDailyService.getCurrentDayHabitDailySummaryListLocal();
      final isNeedSync = habitDailyService.isNeedSync();
      state = state.copyWith(
        isLoading: false,
        currentMonth: formattedDate,
        lastSevenDays: listHabit,
        isError: false,
        currentProgress: currentProgress,
        isNeedSync: isNeedSync,
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on fetchData() method',
      );
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
