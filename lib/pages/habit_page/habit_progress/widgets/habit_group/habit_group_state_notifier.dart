import 'dart:io';

import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_group_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:retrofit/retrofit.dart';

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
  HabitGroupStateNotifier({
    required HabitGroupApi habitGroupApi,
  })  : _habitGroupApi = habitGroupApi,
        super(HabitGroupState());

  final HabitGroupApi _habitGroupApi;

  @override
  Future<void> initStateNotifier() async {
    await fetchData();
  }

  Future<void> createGroup(String groupName) async {
    final HttpResponse<CreateHabitGroupResponse> request =
        await _habitGroupApi.createGroup(
      request: CreateHabitGroupRequest(
        name: groupName,
        date: DateUtils.getCurrentDateInString(),
      ),
    );

    if (request.response.statusCode != 200) {
      return;
    }

    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      state = state.copyWith(isLoading: true);
      Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false);
    } on SocketException catch (_) {
      state = state.copyWith(hasInternet: false);
    } catch (e) {
      state = state.copyWith(isSuccessLoad: false);
    }
  }
}
