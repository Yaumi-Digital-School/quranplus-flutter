import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_seven_days_item.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class HabitProgressState {
  bool? isLoading = true;
  bool? isError = false;
  String? currentMonth = "";
  HabitDailySummary? currentProgress;
  List<HabitDailySevenDaysItem>? lastSevenDays = [];

  HabitProgressState({
    this.isLoading,
    this.currentMonth,
    this.lastSevenDays,
    this.isError,
    this.currentProgress,
  });

  HabitProgressState copyWith({
    bool? isLoading,
    String? currentMonth,
    List<HabitDailySevenDaysItem>? lastSevenDays,
    bool? isError,
    HabitDailySummary? currentProgress,
  }) {
    return HabitProgressState(
      isLoading: isLoading ?? this.isLoading,
      currentMonth: currentMonth ?? this.currentMonth,
      lastSevenDays: lastSevenDays ?? this.lastSevenDays,
      isError: isError ?? this.isError,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

class HabitProgressStateNotifier extends BaseStateNotifier<HabitProgressState> {
  HabitProgressStateNotifier({
    required HabitDailySummaryService habitDailySummaryService,
  })  : _habitDailyService = habitDailySummaryService,
        super(HabitProgressState());

  late DbLocal db;
  final HabitDailySummaryService _habitDailyService;

  @override
  Future<void> initStateNotifier() async {
    try {
      db = DbLocal();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MMMM yyyy').format(now);
      final List<HabitDailySevenDaysItem> listHabit =
          await db.getLastSevenDays(now);
      final HabitDailySummary currentProgress =
          await _habitDailyService.getCurrentDayHabitDailySummaryListLocal();
      state = state.copyWith(
        isLoading: false,
        currentMonth: formattedDate,
        lastSevenDays: listHabit,
        isError: false,
        currentProgress: currentProgress,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
