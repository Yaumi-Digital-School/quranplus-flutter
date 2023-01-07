import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

enum HabitProgressTab {
  personal,
  group,
}

class HabitProgressState {
  final HabitProgressTab habitProgressTab;

  const HabitProgressState({required this.habitProgressTab});

  HabitProgressState copyWith({HabitProgressTab? habitProgressTab}) {
    return HabitProgressState(
      habitProgressTab: habitProgressTab ?? this.habitProgressTab,
    );
  }
}

class HabitProgressStateNotifier extends BaseStateNotifier<HabitProgressState> {
  HabitProgressStateNotifier()
      : super(const HabitProgressState(
          habitProgressTab: HabitProgressTab.personal,
        ));

  @override
  initStateNotifier() {}

  void changeTab(HabitProgressTab tab) {
    state = state.copyWith(habitProgressTab: tab);
  }
}
