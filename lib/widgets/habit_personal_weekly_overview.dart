import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';

enum HabitPersonalWeeklyOverviewType {
  withPersonalInformation,
  withCurrentMonthInformation,
}

class HabitPersonalWeeklyOverviewWidget extends StatefulWidget {
  const HabitPersonalWeeklyOverviewWidget({
    Key? key,
    required this.sevenDaysPersonalInfo,
    required this.type,
    this.onTapDailySummary,
    this.selectedIdx,
    this.name,
    this.startEnabledProgressDate,
    this.isAdmin = false,
  }) : super(key: key);

  final List<HabitDailySummary> sevenDaysPersonalInfo;
  final HabitPersonalWeeklyOverviewType type;
  final String? name;
  final DateTime? startEnabledProgressDate;
  final Function(String)? onTapDailySummary;
  final int? selectedIdx;
  final bool isAdmin;

  @override
  State<HabitPersonalWeeklyOverviewWidget> createState() =>
      _HabitPersonalWeeklyOverviewWidgetState();
}

class _HabitPersonalWeeklyOverviewWidgetState
    extends State<HabitPersonalWeeklyOverviewWidget> {
  String? dateInformation;
  late DateTime cleanDateNow;

  @override
  void initState() {
    if (widget.type ==
        HabitPersonalWeeklyOverviewType.withCurrentMonthInformation) {
      dateInformation = DateFormat('MMMM yyyy').format(DateTime.now());
    }

    final DateTime now = DateTime.now();
    cleanDateNow = DateTime(now.year, now.month, now.day);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        color: QPColors.getColorBasedTheme(
          dark: QPColors.darkModeFair,
          light: QPColors.whiteFair,
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
      ),
      child: Column(
        children: [
          _buildDetailInformation(context),
          _buildWeeklyRecapInformations(widget.sevenDaysPersonalInfo, context),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecapInformations(
    List<HabitDailySummary> summaries,
    BuildContext context,
  ) {
    List<Widget> recaps = <Widget>[];

    for (int i = 0; i < summaries.length; i++) {
      recaps.add(
        _buildDailyRecapInformation(summaries[i], i, context),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: recaps,
      ),
    );
  }

  Widget _buildDetailInformation(BuildContext context) {
    if (widget.type ==
            HabitPersonalWeeklyOverviewType.withCurrentMonthInformation &&
        dateInformation != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          dateInformation!,
          style: QPTextStyle.getSubHeading3SemiBold(context),
        ),
      );
    }

    if (widget.type ==
            HabitPersonalWeeklyOverviewType.withPersonalInformation &&
        widget.name != null) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 13,
          bottom: 10,
          left: 15,
          right: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name!,
              style: QPTextStyle.getSubHeading3SemiBold(context),
            ),
            if (widget.isAdmin)
              Text(
                'Admin',
                style: QPTextStyle.getSubHeading4Regular(context).copyWith(
                  // Todo: check color based on theme
                  color: QPColors.brandFair,
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDailyRecapInformation(
    HabitDailySummary item,
    int idxInList,
    BuildContext context,
  ) {
    final int? selectedPersonalInformationIdx = widget.selectedIdx;
    final String nameOfDay =
        DateFormat('EEEE').format(item.date).substring(0, 3);
    final String numberOfDay = DateFormat('d').format(item.date);
    final bool isToday = cleanDateNow.difference(item.date).inDays == 0;
    final bool isBeforeToday = item.date.difference(cleanDateNow).inDays < 0;
    final bool isAfterToday = item.date.difference(cleanDateNow).inDays > 0;
    final bool isSelected =
        (selectedPersonalInformationIdx == null && isToday) ||
            (selectedPersonalInformationIdx != null &&
                selectedPersonalInformationIdx == idxInList);

    final bool isDisabled = (widget.startEnabledProgressDate != null &&
        widget.startEnabledProgressDate!.difference(item.date).inDays > 0);

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

    if (!isDisabled && isBeforeToday) {
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
            if (!isAfterToday &&
                widget.onTapDailySummary != null &&
                !isDisabled) {
              widget.onTapDailySummary!(item.date.toIso8601String());
            }
          },
          child: Container(
            decoration: decoration,
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: 37,
            child: Column(
              children: [
                Text(
                  numberOfDay,
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
                    totalPages: item.totalPages,
                    target: item.target,
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

  String _buildUrlStar({
    int totalPages = 0,
    int target = 0,
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

    if (target != 0) {
      progress = totalPages / target;
    }

    if (progress == 0) {
      return ImagePath.activeProgressEmpty;
    }

    if (progress < 1) {
      return ImagePath.activeProgressHalf;
    }

    return ImagePath.activeProgressFull;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
