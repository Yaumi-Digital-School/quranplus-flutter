import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/widgets/habit_group_empty_group_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/widgets/habit_group_list_view.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

import 'habit_group_state_notifier.dart';
import 'widgets/habit_group_create_group_bottom_sheet.dart';

class HabitGroupView extends ConsumerWidget {
  const HabitGroupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitGroupProvider);
    final notifier = ref.read(habitGroupProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 24, left: 24, top: 32),
          child: state.listGroup.isNotEmpty
              ? HabitGroupListView(
                  listGroup: state.listGroup,
                  onEditedGroupName: notifier.refresh,
                )
              : HabitGroupEmptyGroupView(
                  onSubmitCreateGroup: (String value) =>
                      notifier.createGroup(value),
                ),
        ),
        if (state.listGroup.isNotEmpty)
          Positioned(
            right: 24,
            bottom: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 48,
              icon: const Icon(
                Icons.add_circle_outlined,
                color: QPColors.brandFair,
              ),
              onPressed: () {
                HabitGroupCreateGroupBottomSheet.showModalCreateGroup(
                  context: context,
                  onSubmit: (String value) => notifier.createGroup(value),
                );
              },
            ),
          ),
      ],
    );
  }
}
