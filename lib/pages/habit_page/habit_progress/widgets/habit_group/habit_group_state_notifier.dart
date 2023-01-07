import 'dart:io';

import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class HabitGroupState {
  List<dynamic> listGroup;
  bool isLoading;
  bool hasInternet;
  bool isSuccessLoad;

  HabitGroupState({
    this.listGroup = const [],
    this.isLoading = true,
    this.hasInternet = true,
    this.isSuccessLoad = true,
  });

  HabitGroupState copyWith({
    List<dynamic>? listGroup,
    bool? isLoading,
    bool? hasInternet,
    bool? isSuccessLoad,
  }) {
    return HabitGroupState(
      listGroup: listGroup ?? this.listGroup,
      isLoading: isLoading ?? this.isLoading,
      hasInternet: hasInternet ?? this.hasInternet,
      isSuccessLoad: isSuccessLoad ?? this.isSuccessLoad,
    );
  }
}

class HabitGroupStateNotifier extends BaseStateNotifier<HabitGroupState> {
  HabitGroupStateNotifier() : super(HabitGroupState());

  @override
  initStateNotifier() async {
    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false, listGroup: ["hehe"]);
    } on SocketException catch (_) {
      state = state.copyWith(hasInternet: false);
    } catch (e) {
      state = state.copyWith(isSuccessLoad: false);
    }
  }
}
