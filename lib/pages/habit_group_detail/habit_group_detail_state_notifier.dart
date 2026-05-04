import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/user_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_group_detail_state_notifier.g.dart';

class HabitGroupDetailState {
  HabitGroupDetailState({
    this.groupSummaries,
    this.isLoading = true,
    this.isErrorOnFetching = false,
    this.isFetchUserSummary = false,
    this.selectedSummaryIdx,
    this.memberSummaries,
    this.isCurrentUser = false,
    this.groupName = '',
    this.userSummaryResponse,
  });

  final List<HabitGroupSummary>? groupSummaries;
  final List<GetHabitGroupMemberPersonalItemResponse>? memberSummaries;
  final int? selectedSummaryIdx;
  final bool isLoading;
  final bool isFetchUserSummary;
  final bool isCurrentUser;
  final bool isErrorOnFetching;
  final String groupName;
  final UserSummaryResponse? userSummaryResponse;

  HabitGroupDetailState copyWith({
    List<HabitGroupSummary>? groupSummaries,
    List<GetHabitGroupMemberPersonalItemResponse>? memberSummaries,
    bool? isLoading,
    bool? isFetchUserSummary,
    bool? isErrorOnFetching,
    bool? isCurrentUser,
    int? selectedSummaryIdx,
    String? groupName,
    UserSummaryResponse? userSummaryResponse,
  }) {
    return HabitGroupDetailState(
      groupSummaries: groupSummaries ?? this.groupSummaries,
      isLoading: isLoading ?? this.isLoading,
      selectedSummaryIdx: selectedSummaryIdx ?? this.selectedSummaryIdx,
      isErrorOnFetching: isErrorOnFetching ?? this.isErrorOnFetching,
      isFetchUserSummary: isFetchUserSummary ?? this.isFetchUserSummary,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      memberSummaries: memberSummaries ?? this.memberSummaries,
      groupName: groupName ?? this.groupName,
      userSummaryResponse: userSummaryResponse,
    );
  }
}

@riverpod
class HabitGroupDetailNotifier extends _$HabitGroupDetailNotifier {
  bool groupNameIsEdited = false;
  bool isLeaveGrup = false;
  DateTime? groupCreatedAt;

  int _groupId = 0;
  List<HabitGroupSummary>? _groupSummaries;
  List<GetHabitGroupMemberPersonalItemResponse>? _memberSummaries;

  @override
  HabitGroupDetailState build(int groupId) {
    _groupId = groupId;
    Future.microtask(() => _load(groupId));
    return HabitGroupDetailState();
  }

  Future<void> _load(int groupId) async {
    state = state.copyWith(isLoading: true);
    await _getHabitGroupDetail(groupId);
    await _getGroupMemberSummaries(groupId);

    if (!state.isErrorOnFetching) {
      state = state.copyWith(
        isLoading: false,
        groupSummaries: _groupSummaries,
        memberSummaries: _memberSummaries,
      );
    }
  }

  bool get userIsAdmin => _memberSummaries?[0].isAdmin ?? false;

  Future<void> _getHabitGroupDetail(int groupId) async {
    final api = ref.read(habitGroupApiProvider);
    final response = await api.getHabitGroupDetail(
      groupId: groupId,
      param: GetHabitGroupDetailParam(
        startDate: DateCustomUtils.getFirstDayOfTheWeekFromToday(),
        endDate: DateCustomUtils.getLastDayOfTheWeekFromToday(),
      ),
    );

    if (response.response.statusCode != 200) {
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);
      return;
    }

    _groupSummaries = response.data.completions
        .map((e) => HabitGroupSummary.fromGetGroupDetailCompletionItem(e))
        .toList();

    groupCreatedAt = response.data.createdAt;
    state = state.copyWith(groupName: response.data.name);
  }

  Future<void> renameGroup(String newName) async {
    final api = ref.read(habitGroupApiProvider);
    final HttpResponse<bool> request = await api.renameGroup(
      request: UpdateHabitGroupRequest(newName: newName),
      groupId: _groupId,
    );

    if (request.response.statusCode != 200) {
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);
      return;
    }

    if (request.data) {
      groupNameIsEdited = true;
      await _load(_groupId);
    }
  }

  Future<void> _getGroupMemberSummaries(int groupId) async {
    final api = ref.read(habitGroupApiProvider);
    final response = await api.getHabitGroupMemberSummaries(
      groupId: groupId,
      param: GetHabitGroupMemberSummariesParam(
        startDate: DateCustomUtils.getFirstDayOfTheWeekFromToday(),
        endDate: DateCustomUtils.getLastDayOfTheWeekFromToday(),
      ),
    );

    if (response.response.statusCode != 200) {
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);
      return;
    }

    _memberSummaries = response.data;
  }

  void onTapGroupCompletionSummaryData(int tappedIdx) {
    state = state.copyWith(selectedSummaryIdx: tappedIdx);
  }

  void onSelectUserSummary(int id, String date, bool isCurrentUser) async {
    try {
      state = state.copyWith(isFetchUserSummary: true);
      final response = await ref.read(habitApiProvider).getUserSummary(
        userId: id,
        param: UserSummaryRequest(date: date),
      );
      state = state.copyWith(
        isFetchUserSummary: false,
        userSummaryResponse: response.data,
        isCurrentUser: isCurrentUser,
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on onSelectUserSummary() method',
      );
      state = state.copyWith(isFetchUserSummary: false);
    }
  }

  Future<void> leaveGroup(int groupId) async {
    final api = ref.read(habitGroupApiProvider);
    final HttpResponse<bool> request = await api.leaveGroup(
      groupId: groupId,
      request: LeaveHabitGroupRequest(
        date: DateCustomUtils.getCurrentDateInString(),
      ),
    );

    if (request.response.statusCode != 200) {
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);
      return;
    }

    if (request.data) {
      isLeaveGrup = true;
    }
  }
}
