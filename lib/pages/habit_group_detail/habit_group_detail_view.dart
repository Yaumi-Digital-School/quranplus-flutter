import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/group_detall_bottomsheet.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/group_summary_card.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/widgets/user_summary_bottomsheet.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/habit_group.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/dynamic_link_helper.dart';
import 'package:qurantafsir_flutter/widgets/habit_personal_weekly_overview.dart';

import '../habit_page/habit_progress/habit_progress_view.dart';

class HabitGroupDetailViewParam {
  HabitGroupDetailViewParam({
    required this.id,
    this.isSuccessJoinGroup = false,
  });

  final int id;
  final bool isSuccessJoinGroup;
}

class HabitGroupDetailView extends ConsumerStatefulWidget {
  const HabitGroupDetailView({
    super.key,
    required this.param,
  });

  final HabitGroupDetailViewParam param;

  @override
  ConsumerState<HabitGroupDetailView> createState() =>
      _HabitGroupDetailViewState();
}

class _HabitGroupDetailViewState extends ConsumerState<HabitGroupDetailView> {
  bool _successSheetShown = false;

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(habitGroupDetailProvider(widget.param.id));
    final notifier =
        ref.read(habitGroupDetailProvider(widget.param.id).notifier);

    ref.listen(habitGroupDetailProvider(widget.param.id), (prev, next) {
      if (prev?.isLoading == true &&
          next.isLoading == false &&
          widget.param.isSuccessJoinGroup &&
          !_successSheetShown) {
        _successSheetShown = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          HabitGroupBottomSheet.showModalSuccessJoinGroup(context: context);
        });
      }

      if (next.userSummaryResponse != null &&
          prev?.userSummaryResponse != next.userSummaryResponse) {
        Future.delayed(const Duration(milliseconds: 0), () {
          if (!mounted) return;
          UserSummaryBottomSheet.showBottomSheet(
            context: context,
            data: next.userSummaryResponse!,
            isCurrentUser: next.isCurrentUser,
          );
        });
      }
    });

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onTapBack(context, notifier.groupNameIsEdited);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(54.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteFair,
                  light: QPColors.blackSoft,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
                size: 30,
              ),
              onPressed: () {
                _onTapBack(context, notifier.groupNameIsEdited);
              },
            ),
            automaticallyImplyLeading: false,
            elevation: 0.7,
            centerTitle: true,
            title: Text(
              state.groupName,
              style: QPTextStyle.getSubHeading2SemiBold(context),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              Theme(
                data: Theme.of(context).copyWith(
                  iconTheme: IconThemeData(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteMassive,
                      light: QPColors.blackMassive,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
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
                            AssetImage(StoredIcon.iconInviteMember.path),
                            size: 12,
                            color: QPColors.blackMassive,
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Text(
                            "Invite Member",
                            style:
                                QPTextStyle.getSubHeading4SemiBold(context)
                                    .copyWith(
                              color: QPColors.blackMassive,
                            ),
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
                              AssetImage(StoredIcon.iconEditSquare.path),
                              size: 12,
                              color: QPColors.blackMassive,
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Text(
                              "Edit Group Name",
                              style: QPTextStyle.getSubHeading4SemiBold(
                                context,
                              ).copyWith(
                                color: QPColors.blackMassive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          ImageIcon(
                            AssetImage(StoredIcon.iconLeaveGroup.path),
                            size: 12,
                            color: QPColors.blackMassive,
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Text(
                            "Leave Group",
                            style:
                                QPTextStyle.getSubHeading4SemiBold(context)
                                    .copyWith(
                              color: QPColors.blackMassive,
                            ),
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
                    return GroupSummaryCard(state: state, notifier: notifier);
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
                color: Colors.black.withValues(alpha: 0.3),
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
  }

  bool _onTapBack(BuildContext context, bool isGroupNameEdited) {
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

  void _selectedItem({
    required BuildContext context,
    required int item,
    required HabitGroupDetailNotifier notifier,
    required HabitGroupDetailState state,
  }) {
    switch (item) {
      case 0:
        _showModalInviteGroup(context, state.groupName);
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
          onTap: () => notifier.leaveGroup(widget.param.id),
          ref: ref,
          notifier: notifier,
        );
        break;
    }
  }

  Future<void> _showModalInviteGroup(
    BuildContext context,
    String groupName,
  ) async {
    final uri =
        await DynamicLinkHelper().createDynamicLinkInvite(id: widget.param.id);

    if (!context.mounted) return;
    HabitGroupBottomSheet.showModalInviteMemberGroup(
      context: context,
      url: uri.toString(),
      currentGroupName: groupName,
    );
  }
}
