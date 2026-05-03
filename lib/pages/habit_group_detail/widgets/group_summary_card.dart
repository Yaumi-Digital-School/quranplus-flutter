import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';
import 'package:qurantafsir_flutter/widgets/habit_group_overview.dart';

class GroupSummaryCard extends StatelessWidget {
  const GroupSummaryCard({
    super.key,
    required this.state,
    required this.notifier,
  });

  final HabitGroupDetailState state;
  final HabitGroupDetailNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final GetHabitGroupMemberPersonalItemResponse userData =
        state.memberSummaries![0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Member Completion',
          style: QPTextStyle.getSubHeading2SemiBold(context),
        ),
        const SizedBox(height: 16),
        HabitGroupOverviewWidget(
          type: HabitGroupOverviewType.withCurrentMonthInfo,
          sevenDaysInformation:
              state.groupSummaries?.toList() ?? <HabitGroupSummary>[],
          selectedIdx: state.selectedSummaryIdx,
          onTapSummary: notifier.onTapGroupCompletionSummaryData,
          startOfEnabledDate: userData.joinDate,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
