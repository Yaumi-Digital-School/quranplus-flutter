import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/group_detall_bottomsheet.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/user_summary_bottomsheet.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/habit_progress_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/dynamic_link_helper.dart';
import 'package:qurantafsir_flutter/widgets/habit_group_overview.dart';
import 'package:qurantafsir_flutter/widgets/habit_personal_weekly_overview.dart';

class HabitGroupDetailViewParam {
  HabitGroupDetailViewParam({
    required this.id,
    this.isSuccessJoinGroup = false,
  });

  final int id;
  final bool isSuccessJoinGroup;
}

class HabitGroupDetailView extends StatefulWidget {
  const HabitGroupDetailView({
    Key? key,
    required this.param,
  }) : super(key: key);

  final HabitGroupDetailViewParam param;

  @override
  State<HabitGroupDetailView> createState() => _HabitGroupDetailViewState();
}

class _HabitGroupDetailViewState extends State<HabitGroupDetailView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitGroupDetailStateNotifier,
        HabitGroupDetailState>(
      stateNotifierProvider: StateNotifierProvider<
          HabitGroupDetailStateNotifier, HabitGroupDetailState>(
        (ref) {
          return HabitGroupDetailStateNotifier(
            habitGroupApi: ref.watch(habitGroupApiProvider),
            habitApi: ref.watch(habitApiProvider),
            groupId: widget.param.id,
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async {
        await notifier.initStateNotifier();
      },
      builder: (
        _,
        state,
        notifier,
        ref,
      ) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (widget.param.isSuccessJoinGroup) {
          Future.delayed(const Duration(seconds: 1), () {
            HabitGroupBottomSheet.showModalSuccessJoinGroup(context: context);
          });
        }

        if (state.userSummaryResponse != null) {
          Future.delayed(const Duration(milliseconds: 0), () {
            UserSummaryBottomSheet.showBottomSheet(
              context: context,
              data: state.userSummaryResponse!,
              isCurrentUser: state.isCurrentUser,
            );
          });
        }

        return WillPopScope(
          onWillPop: () async {
            return _onTapBack(context, ref, notifier.groupNameIsEdited);
          },
          child: Scaffold(
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
                    _onTapBack(context, ref, notifier.groupNameIsEdited);
                  },
                ),
                automaticallyImplyLeading: false,
                elevation: 0.7,
                centerTitle: true,
                title: Text(
                  state.groupName,
                  style: QPTextStyle.subHeading2SemiBold,
                ),
                backgroundColor: QPColors.whiteFair,
                actions: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      textTheme:
                          const TextTheme().apply(bodyColor: Colors.black),
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
                              ImageIcon(
                                AssetImage(IconPath.iconInviteMember),
                                size: 12,
                              ),
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
                        if (notifier.userIsAdmin)
                          PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: [
                                ImageIcon(
                                  AssetImage(IconPath.iconEditSquare),
                                  size: 12,
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  "Edit Group Name",
                                  style: QPTextStyle.subHeading4SemiBold,
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                            children: [
                              ImageIcon(
                                AssetImage(IconPath.iconLeaveGroup),
                                size: 12,
                              ),
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
                      onSelected: (int item) {
                        _selectedItem(
                          context: context,
                          item: item,
                          notifier: notifier,
                          state: state,
                          ref: ref,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 24,
                    left: 24,
                    top: 24,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.memberSummaries!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildGroupSummary(state, notifier);
                      }

                      final GetHabitGroupMemberPersonalItemResponse userData =
                          state.memberSummaries![0];

                      final GetHabitGroupMemberPersonalItemResponse item =
                          state.memberSummaries![index - 1];

                      final List<HabitDailySummary> dailySummaries = item
                          .summaries
                          .map((e) => HabitDailySummary
                              .fromGetHabitGroupMemberPersonalSummaryItem(e))
                          .toList();

                      final String name =
                          index - 1 == 0 ? 'Your Progress' : item.name;

                      final DateTime startEnabledProgressDate =
                          item.joinDate.difference(userData.joinDate).inDays > 0
                              ? item.joinDate
                              : userData.joinDate;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: HabitPersonalWeeklyOverviewWidget(
                          startEnabledProgressDate: startEnabledProgressDate,
                          selectedIdx: state.selectedSummaryIdx,
                          sevenDaysPersonalInfo: dailySummaries,
                          type: HabitPersonalWeeklyOverviewType
                              .withPersonalInformation,
                          name: name,
                          isAdmin: item.isAdmin,
                          onTapDailySummary: (date) {
                            notifier.onSelectUserSummary(
                              item.userId,
                              date,
                              index == 1,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (state.isFetchUserSummary)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    height: double.infinity,
                    width: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _onTapBack(
    BuildContext context,
    WidgetRef ref,
    bool isGroupNameEdited,
  ) {
    final bool canPop = Navigator.canPop(context);
    if (canPop) {
      Navigator.pop(context, isGroupNameEdited);

      return true;
    }

    const HabitProgressTab selectedTabOnPop = HabitProgressTab.group;

    ref
        .read(mainPageProvider)
        .setHabitGroupProgressSelectedTab(selectedTabOnPop);

    Navigator.pushReplacementNamed(
      context,
      RoutePaths.routeMain,
      arguments: MainPageParam(
        initialSelectedIdx: selectedTabOnPop.index,
      ),
    );

    return true;
  }

  Widget _buildGroupSummary(
    HabitGroupDetailState state,
    HabitGroupDetailStateNotifier notifier,
  ) {
    final GetHabitGroupMemberPersonalItemResponse userData =
        state.memberSummaries![0];

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
              state.groupSummaries?.toList() ?? <HabitGroupSummary>[],
          selectedIdx: state.selectedSummaryIdx,
          onTapSummary: notifier.onTapGroupCompletionSummaryData,
          startOfEnabledDate: userData.joinDate,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _selectedItem({
    required BuildContext context,
    required int item,
    required HabitGroupDetailStateNotifier notifier,
    required HabitGroupDetailState state,
    required WidgetRef ref,
  }) {
    switch (item) {
      case 0:
        _showModalInviteGroup(
          context,
          state,
        );
        break;
      case 1:
        HabitGroupBottomSheet.showModalEditGroupName(
          context: context,
          currentGroupName: state.groupName,
          onSubmit: (value) {
            notifier.renameGroup(value);
          },
        );
        break;
      case 2:
        HabitGroupBottomSheet.showModalLeaveGroup(
          context: context,
          onTap: notifier.leaveGroup,
          ref: ref,
          notifier: notifier,
        );
        break;
    }
  }

  void _showModalInviteGroup(
    BuildContext context,
    HabitGroupDetailState state,
  ) async {
    final uri =
        await DynamicLinkHelper().createDynamicLinkInvite(id: widget.param.id);
    HabitGroupBottomSheet.showModalInviteMemberGroup(
      context: context,
      url: uri.toString(),
      currentGroupName: state.groupName,
    );
  }
}
