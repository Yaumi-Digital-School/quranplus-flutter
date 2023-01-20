import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/habit_progress_state_notifier.dart';

class MainPageProvider {
  MainPageProvider();

  bool _shouldShowSignInBottomSheet = false;
  bool _shouldShowInvalidLink = false;
  bool _shouldShowInvalidGroup = false;

  HabitProgressTab _habitGroupProgressSelectedTab = HabitProgressTab.personal;

  void setShouldShowSignInBottomSheet(bool value) {
    _shouldShowSignInBottomSheet = value;
  }

  void setShouldInvalidLinkBottomSheet(bool value) {
    _shouldShowInvalidLink = value;
  }

  void setShouldInvalidGroupBottomSheet(bool value) {
    _shouldShowInvalidGroup = value;
  }

  bool getShouldSShowInvalidLink() {
    final bool result = _shouldShowInvalidLink;

    _shouldShowInvalidLink = false;

    return result;
  }

  bool getShouldSShowInvalidGroup() {
    final bool result = _shouldShowInvalidGroup;

    _shouldShowInvalidGroup = false;

    return result;
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
