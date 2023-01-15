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
  });

  final List<HabitGroupSummary>? groupSummaries;
  final List<GetHabitGroupMemberPersonalItemResponse>? memberSummaries;
  final int? selectedSummaryIdx;
  final bool isLoading;
  final bool isErrorOnFetching;

  HabitGroupDetailState copyWith({
    List<HabitGroupSummary>? groupSummaries,
    List<GetHabitGroupMemberPersonalItemResponse>? memberSummaries,
    bool? isLoading,
    bool? isErrorOnFetching,
    int? selectedSummaryIdx,
  }) {
    return HabitGroupDetailState(
      groupSummaries: groupSummaries ?? this.groupSummaries,
      isLoading: isLoading ?? this.isLoading,
      selectedSummaryIdx: selectedSummaryIdx ?? this.selectedSummaryIdx,
      isErrorOnFetching: isErrorOnFetching ?? this.isErrorOnFetching,
      memberSummaries: memberSummaries ?? this.memberSummaries,
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

  @override
  Future<void> initStateNotifier() async {
    await _getHabitGroupCompletions();
    await _getGroupMemberSummaries();

    if (!state.isErrorOnFetching) {
      state = state.copyWith(
        isLoading: false,
        groupSummaries: _groupSummaries,
        memberSummaries: _memberSummaries,
      );
    }
  }

  Future<void> _getHabitGroupCompletions() async {
    HttpResponse<List<GetHabitGroupCompletionsItemResponse>>
        habitGroupCompletions = await _habitGroupApi.getHabitGroupCompletions(
      groupId: _groupId,
      param: GetHabitGroupCompletionsParam(
        startDate: DateUtils.getFirstDayOfTheWeekFromToday(),
        endDate: DateUtils.getLastDayOfTheWeekFromToday(),
      ),
    );

    if (habitGroupCompletions.response.statusCode != 200) {
      // need new design on error fetching
      state = state.copyWith(isLoading: false, isErrorOnFetching: true);

      return;
    }

    _groupSummaries = habitGroupCompletions.data
        .map(
          (e) => HabitGroupSummary.fromGetGroupCompletionsItem(e),
        )
        .toList();
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
}
