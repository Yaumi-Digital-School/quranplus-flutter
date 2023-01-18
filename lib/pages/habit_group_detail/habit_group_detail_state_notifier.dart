import 'package:qurantafsir_flutter/shared/core/apis/habit_group_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:retrofit/retrofit.dart';

class HabitGroupDetailState {
  HabitGroupDetailState({
    this.groupSummaries,
    this.isLoading = true,
    this.isErrorOnFetching = false,
    this.selectedSummaryIdx,
    this.memberSummaries,
    this.groupName = '',
  });

  final List<HabitGroupSummary>? groupSummaries;
  final List<GetHabitGroupMemberPersonalItemResponse>? memberSummaries;
  final int? selectedSummaryIdx;
  final bool isLoading;
  final bool isErrorOnFetching;
  final String groupName;

  HabitGroupDetailState copyWith({
    List<HabitGroupSummary>? groupSummaries,
    List<GetHabitGroupMemberPersonalItemResponse>? memberSummaries,
    bool? isLoading,
    bool? isErrorOnFetching,
    int? selectedSummaryIdx,
    String? groupName,
  }) {
    return HabitGroupDetailState(
      groupSummaries: groupSummaries ?? this.groupSummaries,
      isLoading: isLoading ?? this.isLoading,
      selectedSummaryIdx: selectedSummaryIdx ?? this.selectedSummaryIdx,
      isErrorOnFetching: isErrorOnFetching ?? this.isErrorOnFetching,
      memberSummaries: memberSummaries ?? this.memberSummaries,
      groupName: groupName ?? this.groupName,
    );
  }
}

class HabitGroupDetailStateNotifier
    extends BaseStateNotifier<HabitGroupDetailState> {
  HabitGroupDetailStateNotifier({
    required HabitGroupApi habitGroupApi,
    required int groupId,
  })  : _habitGroupApi = habitGroupApi,
        _groupId = groupId,
        super(
          HabitGroupDetailState(),
        );

  final HabitGroupApi _habitGroupApi;
  List<HabitGroupSummary>? _groupSummaries;
  final int _groupId;
  List<GetHabitGroupMemberPersonalItemResponse>? _memberSummaries;

  bool _groupNameIsEdited = false;
  bool get groupNameIsEdited => _groupNameIsEdited;

  bool _isLeaveGroup = false;
  bool get isLeaveGrup => _isLeaveGroup;

  String _groupName = '';
  DateTime? _groupCreatedAt;
  DateTime? get groupCreatedAt => _groupCreatedAt;

  @override
  Future<void> initStateNotifier() async {
    state = state.copyWith(isLoading: true);

    await _getHabitGroupDetail();
    await _getGroupMemberSummaries();

    if (!state.isErrorOnFetching) {
      state = state.copyWith(
        isLoading: false,
        groupSummaries: _groupSummaries,
        memberSummaries: _memberSummaries,
        groupName: _groupName,
      );
    }
  }

  bool get userIsAdmin => _memberSummaries?[0].isAdmin ?? false;

  Future<void> _getHabitGroupDetail() async {
    HttpResponse<GetHabitGroupDetailResponse> habitGroupDetail =
        await _habitGroupApi.getHabitGroupDetail(
      groupId: _groupId,
      param: GetHabitGroupDetailParam(
        startDate: DateUtils.getFirstDayOfTheWeekFromToday(),
        endDate: DateUtils.getLastDayOfTheWeekFromToday(),
      ),
    );

    if (habitGroupDetail.response.statusCode != 200) {
      // need new design on error fetching
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);

      return;
    }

    _groupSummaries = habitGroupDetail.data.completions
        .map(
          (e) => HabitGroupSummary.fromGetGroupDetailCompletionItem(e),
        )
        .toList();

    _groupName = habitGroupDetail.data.name;
    _groupCreatedAt = habitGroupDetail.data.createdAt;
  }

  Future<void> renameGroup(String newName) async {
    HttpResponse<bool> request = await _habitGroupApi.renameGroup(
      request: UpdateHabitGroupRequest(newName: newName),
      groupId: _groupId,
    );

    if (request.response.statusCode != 200) {
      // need new design on error fetching
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);

      return;
    }

    if (request.data) {
      _groupNameIsEdited = true;
      await initStateNotifier();
    }
  }

  Future<void> _getGroupMemberSummaries() async {
    HttpResponse<List<GetHabitGroupMemberPersonalItemResponse>>
        habitGroupMemberSummaries =
        await _habitGroupApi.getHabitGroupMemberSummaries(
      groupId: _groupId,
      param: GetHabitGroupMemberSummariesParam(
        startDate: DateUtils.getFirstDayOfTheWeekFromToday(),
        endDate: DateUtils.getLastDayOfTheWeekFromToday(),
      ),
    );

    if (habitGroupMemberSummaries.response.statusCode != 200) {
      // need new design on error fetching
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);

      return;
    }

    _memberSummaries = habitGroupMemberSummaries.data;
  }

  void onTapGroupCompletionSummaryData(int tappedIdx) {
    state = state.copyWith(selectedSummaryIdx: tappedIdx);
  }

  Future<void> leaveGroup() async {
    final HttpResponse<bool> request = await _habitGroupApi.leaveGroup(
      groupId: _groupId,
      request: LeaveHabitGroupRequest(
        date: DateUtils.getCurrentDateInString(),
      ),
    );

    if (request.response.statusCode != 200) {
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);

      return;
    }

    if (request.data) {
      _isLeaveGroup = true;
    }
  }
}
