import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/widgets/habit_group_empty_group_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/widgets/habit_group_list_view.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

import 'widgets/habit_group_create_group_bottom_sheet.dart';
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
          return HabitGroupStateNotifier(
            habitGroupApi: ref.watch(habitGroupApiProvider),
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async {
        final ConnectivityResult connection =
            await Connectivity().checkConnectivity();

        if (connection == ConnectivityResult.none) {
          await GeneralBottomSheet().showNoInternetBottomSheet(
            context,
            () async {
              Navigator.pop(context);
            },
          );
        }

        await notifier.initStateNotifier();
      },
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
            Padding(
              padding: const EdgeInsets.only(
                right: 24,
                left: 24,
                top: 32,
              ),
              child: state.listGroup.isNotEmpty
                  ? HabitGroupListView(
                      listGroup: state.listGroup,
                      onEditedGroupName: notifier.initStateNotifier,
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
                      onSubmit: (String value) => notifier.createGroup(value),
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
