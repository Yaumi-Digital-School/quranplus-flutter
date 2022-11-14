import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/habit_daily_seven_days_item.dart';

import '../../../shared/core/database/dbLocal.dart';
import '../../../shared/core/state_notifiers/base_state_notifier.dart';

class HabitProgressState {
  bool? isLoading = true;
  bool? isError = false;
  String? currentMonth = "";
  List<HabitDailySevenDaysItem>? lastSevenDays = [];

  HabitProgressState({
    this.isLoading,
    this.currentMonth,
    this.lastSevenDays,
    this.isError,
  });

  HabitProgressState copyWith({
    bool? isLoading,
    String? currentMonth,
    List<HabitDailySevenDaysItem>? lastSevenDays,
    bool? isError,
  }) {
    return HabitProgressState(
      isLoading: isLoading ?? this.isLoading,
      currentMonth: currentMonth ?? this.currentMonth,
      lastSevenDays: lastSevenDays ?? this.lastSevenDays,
      isError: isError ?? this.isError,
    );
  }
}

class HabitProgressStateNotifier extends BaseStateNotifier<HabitProgressState> {
  HabitProgressStateNotifier() : super(HabitProgressState());
  late DbLocal db;

  @override
  Future<void> initStateNotifier() async {
    try {
      db = DbLocal();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MMMM yyyy').format(now);
      final listHabit = await db.getLastSevenDays(now);
      state = state.copyWith(
        isLoading: false,
        currentMonth: formattedDate,
        lastSevenDays: listHabit,
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
