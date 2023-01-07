import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/habit_group_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_personal/habit_personal_view.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

import 'habit_progress_state_notifier.dart';

class HabitProgressView extends StatelessWidget {
  const HabitProgressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitProgressStateNotifier,
        HabitProgressState>(
      stateNotifierProvider:
          StateNotifierProvider<HabitProgressStateNotifier, HabitProgressState>(
        (StateNotifierProviderRef<HabitProgressStateNotifier,
                HabitProgressState>
            ref) {
          return HabitProgressStateNotifier();
        },
      ),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        HabitProgressState state,
        HabitProgressStateNotifier notifier,
        WidgetRef ref,
      ) {
        return Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(22)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabWidget(
                      "Personal",
                      HabitProgressTab.personal,
                      notifier,
                      state,
                    ),
                  ),
                  Expanded(
                    child: _buildTabWidget(
                      "Group",
                      HabitProgressTab.group,
                      notifier,
                      state,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.habitProgressTab == HabitProgressTab.personal
                  ? const HabitPersonalView()
                  : const HabitGroupView(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabWidget(
    String title,
    HabitProgressTab tab,
    HabitProgressStateNotifier notifier,
    HabitProgressState state,
  ) {
    return InkWell(
      onTap: () {
        notifier.changeTab(tab);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color:
              state.habitProgressTab == tab ? QPColors.brandFair : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
        ),
        child: Text(
          title,
          style: QPTextStyle.subHeading4SemiBold.copyWith(
            color: state.habitProgressTab == tab
                ? Colors.white
                : QPColors.brandFair,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
