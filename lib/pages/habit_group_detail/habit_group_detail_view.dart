import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_grup_invite_member.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

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
          return HabitGroupDetailStateNotifier();
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
        );
      },
    );
  }

  void _selectedItem(BuildContext context, item) {
    switch (item) {
      case 0:
        HabitGroupInviteMemberBottomSheet.showModalCreateGroup(
          context: context,
        );
        break;
      case 1:
        break;
    }
  }
}
