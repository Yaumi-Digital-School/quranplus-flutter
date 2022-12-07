import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_sync.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class HabitProgressState {
  bool isLoading;
  bool? isError = false;
  String? currentMonth = "";
  HabitDailySummary? currentProgress;
  List<HabitDailySummary>? lastSevenDays = [];

  HabitProgressState({
    this.isLoading = true,
    this.currentMonth,
    this.lastSevenDays,
    this.isError,
    this.currentProgress,
  });

  HabitProgressState copyWith({
    bool? isLoading,
    String? currentMonth,
    List<HabitDailySummary>? lastSevenDays,
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
    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      state = state.copyWith(
        isLoading: true,
      );
      db = DbLocal();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MMMM yyyy').format(now);
      final List<HabitDailySummary> listHabit = await db.getLastSevenDays(now);
      final HabitDailySummary currentProgress =
          await _habitDailyService.getCurrentDayHabitDailySummaryListLocal();

      state = state.copyWith(
        isLoading: false,
        currentMonth: formattedDate,
        lastSevenDays: listHabit,
        isError: false,
        currentProgress: currentProgress,
      );
      _habitDailyService.syncHabit();
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
