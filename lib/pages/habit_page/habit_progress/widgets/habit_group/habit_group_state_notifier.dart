import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/apis/habit_group_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:retrofit/retrofit.dart';

class HabitGroupState {
  List<GetHabitGroupsItem> listGroup;
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
    List<GetHabitGroupsItem>? listGroup,
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
    state = state.copyWith(isLoading: true);
    await _getAllGroups();
  }

  Future<void> createGroup(String groupName) async {
    state = state.copyWith(isLoading: true);
    final HttpResponse<CreateHabitGroupResponse> request =
        await _habitGroupApi.createGroup(
      request: CreateHabitGroupRequest(
        name: groupName,
        date: DateCustomUtils.getCurrentDateInString(),
      ),
    );

    if (request.response.statusCode != 200) {
      state = state.copyWith(isSuccessLoad: false);

      return;
    }

    await _getAllGroups();
  }

  Future<void> _getAllGroups() async {
    final String firstDayOfTheWeek =
        DateCustomUtils.getFirstDayOfTheWeekFromToday();
    final String lastDayOfTheWeek =
        DateCustomUtils.getLastDayOfTheWeekFromToday();

    try {
      final HttpResponse<List<GetHabitGroupsItem>> request =
          await _habitGroupApi.getAllGroups(
        param: GetHabitGroupsParam(
          startDate: firstDayOfTheWeek,
          endDate: lastDayOfTheWeek,
        ),
      );

      if (request.response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          listGroup: request.data,
        );

        return;
      }

      state = state.copyWith(isSuccessLoad: false);
    } on SocketException catch (_) {
      state = state.copyWith(hasInternet: false);
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getAllGroups() method',
      );

      state = state.copyWith(isSuccessLoad: false);
    }
  }
}
