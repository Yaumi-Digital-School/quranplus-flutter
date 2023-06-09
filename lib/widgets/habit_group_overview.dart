import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';

enum HabitGroupOverviewType {
  withGroupDetailInfo,
  withCurrentMonthInfo,
}

class HabitGroupOverviewWidget extends StatelessWidget {
  HabitGroupOverviewWidget({
    Key? key,
    this.groupName,
    required this.sevenDaysInformation,
    this.type = HabitGroupOverviewType.withGroupDetailInfo,
    this.onTapGroupDetailCTA,
    this.onTapSummary,
    this.selectedIdx,
    this.totalMembers = 1,
    this.startOfEnabledDate,
  }) : super(key: key);

  final String? groupName;
  final int totalMembers;
  final List<HabitGroupSummary> sevenDaysInformation;
  final HabitGroupOverviewType type;
  final VoidCallback? onTapGroupDetailCTA;
  final Function(int)? onTapSummary;
  final int? selectedIdx;
  final DateTime now = DateTime.now();
  final DateTime? startOfEnabledDate;
  final int numberOfDaysInAWeek = 7;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapGroupDetailCTA,
      child: Container(
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
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Column(
          children: [
            if (type == HabitGroupOverviewType.withGroupDetailInfo)
              _buildGroupDetailNavigationCTA(context),
            if (type == HabitGroupOverviewType.withCurrentMonthInfo)
              _buildCurrentMonthInformation(context),
            _buildGroupOverviewInformationSection(context),
          ],
        ),
      ),
    );
  }

  String _buildUrlStar({
    int memberCount = 0,
    int completeCount = 0,
    bool isInactive = false,
    bool isDisabled = false,
  }) {
    if (isInactive) {
      return ImagePath.inactiveProgressEmpty;
    }

    if (isDisabled) {
      return ImagePath.disabledProgressEmpty;
    }

    double progress = 0;

    if (memberCount != 0) {
      progress = completeCount / memberCount;
    }

    if (progress == 0) {
      return ImagePath.activeProgressEmpty;
    }

    if (progress < 1) {
      return ImagePath.activeProgressHalf;
    }

    return ImagePath.activeProgressFull;
  }

  Widget _buildDailyRecapInformation({
    required HabitGroupSummary item,
    required int idxInList,
    required BuildContext context,
  }) {
    final String nameOfDay =
        DateFormat('EEEE').format(item.date).substring(0, 3);
    final DateTime cleanDate = DateTime(now.year, now.month, now.day);
    final bool isAfterToday = item.date.difference(cleanDate).inDays > 0;
    final bool isBeforeToday = cleanDate.difference(item.date).inDays > 0;
    final bool isToday = cleanDate.difference(item.date).inDays == 0;

    final bool isSelected = (selectedIdx == null && isToday) ||
        (selectedIdx != null && selectedIdx == idxInList);

    final bool isDisabled = (startOfEnabledDate != null &&
        startOfEnabledDate!.difference(item.date).inDays > 0);

    BoxDecoration decoration = BoxDecoration(
      color: QPColors.getColorBasedTheme(
        dark: Colors.transparent,
        light: Colors.transparent,
        brown: QPColors.brownModeRoot,
        context: context,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
    );

    if (isToday) {
      final Color isTodayColor = QPColors.getColorBasedTheme(
        dark: Colors.transparent,
        light: Colors.transparent,
        brown: QPColors.whiteFair,
        context: context,
      );

      decoration = decoration.copyWith(
        border: const Border.fromBorderSide(
          BorderSide(
            color: QPColors.warningFair,
          ),
        ),
        color: isTodayColor,
      );
    }

    if (!isDisabled &&
        isBeforeToday &&
        type == HabitGroupOverviewType.withCurrentMonthInfo) {
      decoration = decoration.copyWith(
        border: isSelected
            ? const Border.fromBorderSide(
                BorderSide(
                  color: QPColors.blackSoft,
                ),
              )
            : null,
      );
    }

    TextStyle dateStyle = QPTextStyle.getSubHeading3SemiBold(context);
    TextStyle dayStyle = QPTextStyle.getDescription2Regular(context);
    if (isDisabled) {
      dateStyle = QPTextStyle.getSubHeading3SemiBold(context).copyWith(
        color: QPColors.getColorBasedTheme(
          dark: QPColors.blackFair,
          light: QPColors.blackSoft,
          brown: QPColors.blackFair,
          context: context,
        ),
      );
      dayStyle = QPTextStyle.getDescription2Regular(context);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!isDisabled && !isAfterToday && onTapSummary != null) {
              onTapSummary!(idxInList);
            }
          },
          child: Container(
            decoration: decoration,
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: 37,
            child: Column(
              children: [
                Text(
                  item.date.day.toString(),
                  style: dateStyle,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  nameOfDay,
                  style: dayStyle,
                ),
                const SizedBox(
                  height: 4,
                ),
                Image.asset(
                  _buildUrlStar(
                    completeCount: item.completeCount,
                    memberCount: item.memberCount,
                    isInactive: isAfterToday,
                    isDisabled: isDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        isSelected
            ? Container(
                decoration: const BoxDecoration(
                  color: QPColors.warningFair,
                  shape: BoxShape.circle,
                ),
                width: 6,
                height: 6,
              )
            : const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildGroupOverviewInformationSection(BuildContext context) {
    List<Widget> items = <Widget>[];
    for (int i = 0; i < numberOfDaysInAWeek; i++) {
      HabitGroupSummary item = sevenDaysInformation[i];
      items.add(
        _buildDailyRecapInformation(
          item: item,
          idxInList: i,
          context: context,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items,
          ),
        ),
        if (type == HabitGroupOverviewType.withGroupDetailInfo)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            child: Text(
              totalMembers == 1
                  ? '$totalMembers member'
                  : '$totalMembers members',
              style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
                color: QPColors.brandFair,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentMonthInformation(BuildContext context) {
    final String current = DateFormat('MMMM yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        current,
        style: QPTextStyle.getSubHeading3SemiBold(context),
      ),
    );
  }

  Widget _buildGroupDetailNavigationCTA(BuildContext context) {
    return GestureDetector(
      onTap: onTapGroupDetailCTA,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    groupName ?? '',
                    style: QPTextStyle.getSubHeading3SemiBold(context),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.blackSoft,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                  size: 30,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Divider(
              color: Theme.of(context).dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}
