import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/widgets/habit_group/widgets/habit_group_create_group_bottom_sheet.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class HabitGroupEmptyGroupView extends StatelessWidget {
  const HabitGroupEmptyGroupView({
    Key? key,
    required this.onSubmitCreateGroup,
  }) : super(key: key);

  final Future<void> Function(String) onSubmitCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tracking your reading habit group",
          style: QPTextStyle.getSubHeading2SemiBold(context),
        ),
        const SizedBox(height: 8),
        Text(
          "In this habit group, all members progress are visible and hopefully can motivate you to read more Qur’an and compete in goodness",
          style: QPTextStyle.getBody3Regular(context).copyWith(
            // Todo: check color based on theme
            color: QPColors.blackFair,
          ),
        ),
        const SizedBox(height: 24),
        _buildCreateNewGroupCard(context),
      ],
    );
  }

  Widget _buildCreateNewGroupCard(BuildContext context) {
    return InkWell(
      onTap: () {
        HabitGroupCreateGroupBottomSheet.showModalCreateGroup(
          context: context,
          onSubmit: onSubmitCreateGroup,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: QPColors.getColorBasedTheme(
            dark: QPColors.darkModeFair,
            light: QPColors.whiteMassive,
            brown: QPColors.brownModeFair,
            context: context,
          ),
          border: Border.fromBorderSide(BorderSide(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.darkModeHeavy,
              light: QPColors.whiteHeavy,
              brown: QPColors.brownModeHeavy,
              context: context,
            ),
          )),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: QPColors.brandSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_add_rounded,
                size: 16,
                color: QPColors.brandFair,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create new group",
                    style: QPTextStyle.getSubHeading3SemiBold(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Set goals, track, and monitor reading progress",
                    style: QPTextStyle.getBody3Regular(
                      context,
                    ).copyWith(
                      color: QPColors.blackFair,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Icon(
              Icons.arrow_forward_ios,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteMassive,
                light: QPColors.blackMassive,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
