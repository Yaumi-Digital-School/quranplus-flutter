import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/habit_group_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_personal/habit_personal_view.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';

enum HabitProgressTab {
  personal,
  group,
}

extension HabitProgressTabIndex on HabitProgressTab {
  int get index {
    switch (this) {
      case HabitProgressTab.group:
        return 1;
      case HabitProgressTab.personal:
      default:
        return 0;
    }
  }
}

class HabitProgressView extends ConsumerStatefulWidget {
  const HabitProgressView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<HabitProgressView> createState() => _HabitProgressViewState();
}

class _HabitProgressViewState extends ConsumerState<HabitProgressView> {
  HabitProgressTab selectedTab = HabitProgressTab.personal;

  @override
  void initState() {
    selectedTab =
        ref.read(mainPageProvider).getAndResetHabitGroupProgressSelectedTab();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
          decoration: BoxDecoration(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.darkModeHeavy,
              light: QPColors.whiteMassive,
              brown: QPColors.brownModeSoft,
              context: context,
            ),
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
                  context,
                ),
              ),
              Expanded(
                child: _buildTabWidget(
                  "Group",
                  HabitProgressTab.group,
                  context,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: selectedTab == HabitProgressTab.personal
              ? const HabitPersonalView()
              : const HabitGroupView(),
        ),
      ],
    );
  }

  Widget _buildTabWidget(
    String title,
    HabitProgressTab tab,
    BuildContext context,
  ) {
    final bool isSelected = selectedTab == tab;
    final Color labelColor = isSelected
        ? QPColors.getColorBasedTheme(
            dark: QPColors.whiteMassive,
            light: QPColors.whiteMassive,
            brown: QPColors.brownModeMassive,
            context: context,
          )
        : QPColors.getColorBasedTheme(
            dark: QPColors.whiteFair,
            light: QPColors.brandFair,
            brown: QPColors.brownModeMassive,
            context: context,
          );

    final Color? indicatorBackgroundColor = isSelected
        ? QPColors.getColorBasedTheme(
            dark: QPColors.blackFair,
            light: QPColors.brandFair,
            brown: QPColors.brownModeHeavy,
            context: context,
          )
        : null;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: indicatorBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
        ),
        child: Text(
          title,
          style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
            color: labelColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
