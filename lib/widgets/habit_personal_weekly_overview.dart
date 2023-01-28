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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        color: QPColors.whiteMassive,
        border: Border.fromBorderSide(
          BorderSide(color: QPColors.whiteRoot),
        ),
      ),
      child: Column(
        children: [
          _buildDetailInformation(),
          _buildWeeklyRecapInformations(widget.sevenDaysPersonalInfo),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecapInformations(List<HabitDailySummary> summaries) {
    List<Widget> recaps = <Widget>[];

    for (int i = 0; i < summaries.length; i++) {
      recaps.add(
        _buildDailyRecapInformation(summaries[i], i),
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

  Widget _buildDetailInformation() {
    if (widget.type ==
            HabitPersonalWeeklyOverviewType.withCurrentMonthInformation &&
        dateInformation != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          dateInformation!,
          style: QPTextStyle.subHeading3SemiBold,
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
              style: QPTextStyle.subHeading3SemiBold.copyWith(
                color: QPColors.brandHeavy,
              ),
            ),
            if (widget.isAdmin)
              Text(
                'Admin',
                style: QPTextStyle.subHeading4Regular.copyWith(
                  color: QPColors.brandFair,
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDailyRecapInformation(HabitDailySummary item, int idxInList) {
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

    BoxDecoration? decoration;
    if (isToday) {
      decoration = const BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(
            color: QPColors.warningFair,
          ),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      );
    }

    if (!isDisabled && isBeforeToday) {
      decoration = BoxDecoration(
        color: QPColors.whiteFair,
        border: isSelected
            ? const Border.fromBorderSide(
                BorderSide(
                  color: QPColors.blackSoft,
                ),
              )
            : null,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      );
    }

    TextStyle dateStyle = QPTextStyle.subHeading3SemiBold;
    TextStyle dayStyle = QPTextStyle.description2Regular;
    if (isDisabled) {
      dateStyle =
          QPTextStyle.subHeading3SemiBold.copyWith(color: QPColors.blackSoft);
      dayStyle =
          QPTextStyle.description2Regular.copyWith(color: QPColors.blackSoft);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!isAfterToday) {
              if (widget.onTapDailySummary != null) {
                widget.onTapDailySummary!(item.date.toIso8601String());
              }
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
