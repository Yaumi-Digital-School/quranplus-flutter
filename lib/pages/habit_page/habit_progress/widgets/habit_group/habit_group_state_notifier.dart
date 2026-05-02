import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_group_state_notifier.g.dart';

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

@riverpod
class HabitGroupNotifier extends _$HabitGroupNotifier {
  @override
  HabitGroupState build() {
    Future.microtask(_getAllGroups);
    return HabitGroupState();
  }

  Future<void> createGroup(String groupName) async {
    state = state.copyWith(isLoading: true);
    final api = ref.read(habitGroupApiProvider);
    final HttpResponse<CreateHabitGroupResponse> request =
        await api.createGroup(
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
    final firstDay = DateCustomUtils.getFirstDayOfTheWeekFromToday();
    final lastDay = DateCustomUtils.getLastDayOfTheWeekFromToday();
    final api = ref.read(habitGroupApiProvider);

    try {
      final HttpResponse<List<GetHabitGroupsItem>> request =
          await api.getAllGroups(
        param: GetHabitGroupsParam(
          startDate: firstDay,
          endDate: lastDay,
        ),
      );

      if (request.response.statusCode == 200) {
        state = state.copyWith(isLoading: false, listGroup: request.data);
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

  Future<void> refresh() => _getAllGroups();
}
