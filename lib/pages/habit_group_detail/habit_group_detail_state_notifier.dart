import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class HabitGroupDetailState {
  HabitGroupDetailState();
}

class HabitGroupDetailStateNotifier
    extends BaseStateNotifier<HabitGroupDetailState> {
  HabitGroupDetailStateNotifier()
      : super(
          HabitGroupDetailState(),
        );

  @override
  void initStateNotifier() {
    // TODO: implement initStateNotifier
    throw UnimplementedError();
  }
}
