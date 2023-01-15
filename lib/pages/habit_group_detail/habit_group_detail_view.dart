import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/group_detall_bottomsheet.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/habit_group_overview.dart';
import 'package:qurantafsir_flutter/widgets/habit_personal_weekly_overview.dart';

class HabitGroupDetailViewParam {
  HabitGroupDetailViewParam({
    required this.id,
    required this.groupName,
  });

  final int id;
  final String groupName;
}

class HabitGroupDetailView extends StatelessWidget {
  const HabitGroupDetailView({
    Key? key,
    required this.param,
  }) : super(key: key);

  final HabitGroupDetailViewParam param;

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitGroupDetailStateNotifier,
        HabitGroupDetailState>(
      stateNotifierProvider: StateNotifierProvider<
          HabitGroupDetailStateNotifier, HabitGroupDetailState>(
        (ref) {
          return HabitGroupDetailStateNotifier(
            habitGroupApi: ref.watch(habitGroupApiProvider),
            groupId: param.id,
          );
        },
      ),
      onStateNotifierReady: (notifier) async {
        notifier.initStateNotifier();
      },
      builder: (
        _,
        state,
        notifier,
        __,
      ) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: QPColors.blackMassive,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              automaticallyImplyLeading: false,
              elevation: 0.7,
              centerTitle: true,
              title: Text(
                param.groupName,
                style: QPTextStyle.subHeading2SemiBold,
              ),
              backgroundColor: QPColors.whiteFair,
              actions: [
                Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: const TextTheme().apply(bodyColor: Colors.black),
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    ),
                  ),
                  child: PopupMenuButton(
                    color: Colors.white,
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            ImageIcon(AssetImage(IconPath.iconInviteMember)),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              "Invite Member",
                              style: QPTextStyle.subHeading4SemiBold,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            ImageIcon(AssetImage(IconPath.iconLeaveGroup)),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              "Leave Group",
                              style: QPTextStyle.subHeading4SemiBold,
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (item) => _selectedItem(context, item),
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(
              right: 24,
              left: 24,
              top: 24,
            ),
            child: Column(
              children: [
                _buildGroupSummary(state, notifier),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.memberSummaries!.length,
                  itemBuilder: (context, index) {
                    final GetHabitGroupMemberPersonalItemResponse item =
                        state.memberSummaries![index];

                    // TODO : remove if BE is fixed
                    // final List<HabitDailySummary> dailySummaries = item
                    //     .summaries
                    //     .map((e) => HabitDailySummary
                    //         .fromGetHabitGroupMemberPersonalSummaryItem(e))
                    //     .toList();

                    List<HabitDailySummary> dailySummaries =
                        <HabitDailySummary>[
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 9),
                      ),
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 10),
                      ),
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 11),
                      ),
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 12),
                      ),
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 13),
                      ),
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 14),
                      ),
                      HabitDailySummary(
                        target: 5,
                        totalPages: 5,
                        date: DateTime(2023, 1, 15),
                      ),
                    ];

                    final String name =
                        index == 0 ? 'Your Progress' : item.name;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: HabitPersonalWeeklyOverviewWidget(
                        selectedIdx: state.selectedSummaryIdx,
                        sevenDaysPersonalInfo: dailySummaries,
                        type: HabitPersonalWeeklyOverviewType
                            .withPersonalInformation,
                        name: name,
                        isAdmin: item.isAdmin,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupSummary(
    HabitGroupDetailState state,
    HabitGroupDetailStateNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Member Completion',
          style: QPTextStyle.subHeading2SemiBold,
        ),
        const SizedBox(height: 16),
        HabitGroupOverviewWidget(
          type: HabitGroupOverviewType.withCurrentMonthInfo,
          sevenDaysInformation:
              state.groupSummaries?.reversed.toList() ?? <HabitGroupSummary>[],
          selectedIdx: state.selectedSummaryIdx,
          onTapSummary: notifier.onTapGroupCompletionSummaryData,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        HabitGroupBottomSheet.showModalInviteMemberGroup(context: context);
        break;
      case 1:
        HabitGroupBottomSheet.showModalLeaveGroup(context: context);
        break;
    }
  }
}
