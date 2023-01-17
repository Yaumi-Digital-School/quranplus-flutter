import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/group_detall_bottomsheet.dart';
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
    required this.groupName,
    this.isSuccessJoinGroup = false,
  });

  final int id;
  final String groupName;
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
    if (widget.param.isSuccessJoinGroup) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (timeStamp) {
          HabitGroupBottomSheet.showModalSuccessJoinGroup(context: context);
        },
      );
    }
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
                  widget.param.groupName,
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
                      onSelected: (int item) => _selectedItem(
                        context,
                        item,
                        notifier,
                      ),
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
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.memberSummaries!.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildGroupSummary(state, notifier);
                  }

                  final GetHabitGroupMemberPersonalItemResponse item =
                      state.memberSummaries![index - 1];

                  // TODO : remove if BE is fixed
                  // final List<HabitDailySummary> dailySummaries = item
                  //     .summaries
                  //     .map((e) => HabitDailySummary
                  //         .fromGetHabitGroupMemberPersonalSummaryItem(e))
                  //     .toList();

                  List<HabitDailySummary> dailySummaries = <HabitDailySummary>[
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 16),
                    ),
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 17),
                    ),
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 18),
                    ),
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 19),
                    ),
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 20),
                    ),
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 21),
                    ),
                    HabitDailySummary(
                      target: 5,
                      totalPages: 5,
                      date: DateTime(2023, 1, 22),
                    ),
                  ];

                  final String name =
                      index - 1 == 0 ? 'Your Progress' : item.name;

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
            ),
          ),
        );
      },
    );
  }

  bool _onTapBack(BuildContext context, WidgetRef ref, bool isGroupNameEdited) {
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

  void _selectedItem(
    BuildContext context,
    int item,
    HabitGroupDetailStateNotifier notifier,
  ) {
    switch (item) {
      case 0:
        _showModalInviteGroup(context);
        break;
      case 1:
        HabitGroupBottomSheet.showModalEditGroupName(
          context: context,
          onSubmit: (value) {
            notifier.renameGroup(value);
          },
        );
        break;
      case 2:
        HabitGroupBottomSheet.showModalLeaveGroup(context: context);
        break;
    }
  }

  void _showModalInviteGroup(BuildContext context) async {
    final uri =
        await DynamicLinkHelper().createDynamicLinkInvite(id: widget.param.id);
    HabitGroupBottomSheet.showModalInviteMemberGroup(
      context: context,
      url: uri.toString(),
    );
  }
}
