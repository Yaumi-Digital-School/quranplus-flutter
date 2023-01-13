import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/habit_group_empty_group_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/habit_group_list_view.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

import 'habit_group_create_group_bottom_sheet.dart';
import 'habit_group_state_notifier.dart';

class HabitGroupView extends StatelessWidget {
  const HabitGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitGroupStateNotifier, HabitGroupState>(
      stateNotifierProvider:
          StateNotifierProvider<HabitGroupStateNotifier, HabitGroupState>(
        (StateNotifierProviderRef<HabitGroupStateNotifier, HabitGroupState>
            ref) {
          return HabitGroupStateNotifier();
        },
      ),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        HabitGroupState state,
        HabitGroupStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: state.listGroup.isNotEmpty
                      ? HabitGroupListView(listGroup: state.listGroup)
                      : const HabitGroupEmptyGroupView(),
                ),
              ],
            ),
            if (state.listGroup.isNotEmpty)
              Positioned(
                right: 24,
                bottom: 40,
                child: IconButton(
                  splashRadius: 24,
                  padding: const EdgeInsets.all(0),
                  iconSize: 48,
                  icon: const Icon(
                    Icons.add_circle,
                    color: QPColors.brandFair,
                  ),
                  onPressed: () {
                    HabitGroupCreateGroupBottomSheet.showModalCreateGroup(
                      context: context,
                      onSubmit: (value) {},
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}