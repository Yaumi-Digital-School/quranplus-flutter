import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/habit_progress_state_notifier.dart';

class MainPageProvider {
  MainPageProvider();

  bool _shouldShowSignInBottomSheet = false;
  HabitProgressTab _habitGroupProgressSelectedTab = HabitProgressTab.personal;

  void setShouldShowSignInBottomSheet(bool value) {
    _shouldShowSignInBottomSheet = value;
  }

  bool getShouldShowSignInBottomSheetAndReset() {
    final bool result = _shouldShowSignInBottomSheet;

    _shouldShowSignInBottomSheet = false;

    return result;
  }

  void setHabitGroupProgressSelectedTab(HabitProgressTab value) {
    _habitGroupProgressSelectedTab = value;
  }

  HabitProgressTab getAndResetHabitGroupProgressSelectedTab() {
    final HabitProgressTab result = _habitGroupProgressSelectedTab;

    _habitGroupProgressSelectedTab = HabitProgressTab.personal;

    return result;
  }
}
