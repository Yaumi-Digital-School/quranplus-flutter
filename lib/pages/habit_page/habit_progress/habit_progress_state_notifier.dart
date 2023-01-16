import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

enum HabitProgressTab {
  personal,
  group,
}

extension HabitProgressTabIndex on HabitProgressTab {
  int get index {
    switch (this) {
      case HabitProgressTab.group:
        return 1;
      case HabitProgressTab.personal:
      default:
        return 0;
    }
  }
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
  HabitProgressStateNotifier({
    this.initialTab = HabitProgressTab.personal,
  }) : super(HabitProgressState(
          habitProgressTab: initialTab,
        ));

  HabitProgressTab initialTab;

  @override
  initStateNotifier() {}

  void changeTab(HabitProgressTab tab) {
    state = state.copyWith(habitProgressTab: tab);
  }
}
