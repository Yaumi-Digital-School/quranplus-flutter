import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_group_summary.dart';

class HabitGroupOverviewWidget extends StatelessWidget {
  HabitGroupOverviewWidget({
    Key? key,
    required this.groupName,
    required this.sevenDaysInformation,
    required this.onTapGroupDetailCTA,
    this.totalMembers = 1,
  }) : super(key: key);

  final String groupName;
  final int totalMembers;
  final List<HabitGroupSummary> sevenDaysInformation;
  final VoidCallback onTapGroupDetailCTA;
  final DateTime now = DateTime.now();
  final int numberOfDaysInAWeek = 7;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: QPColors.whiteMassive,
        border: Border.fromBorderSide(BorderSide(
          color: QPColors.whiteRoot,
        )),
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          _buildGroupDetailNavigationCTA(),
          _buildGroupOverviewInformationSection(),
        ],
      ),
    );
  }

  String _buildUrlStar({
    int memberCount = 0,
    int completeCount = 0,
    bool isInactive = false,
  }) {
    if (isInactive) {
      return ImagePath.inactiveProgressEmpty;
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

  Widget _buildDailyRecapInformation(HabitGroupSummary item) {
    final String nameOfDay =
        DateFormat('EEEE').format(item.date).substring(0, 3);
    final DateTime cleanDate = DateTime(now.year, now.month, now.day);
    final bool isAfterToday = item.date.difference(cleanDate).inDays > 0;
    final bool isToday = cleanDate.difference(item.date).inDays == 0;

    return Column(
      children: [
        Container(
          decoration: isToday
              ? const BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: QPColors.warningFair,
                    ),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                )
              : null,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                item.date.day.toString(),
                style: QPTextStyle.subHeading3SemiBold,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                nameOfDay,
                style: QPTextStyle.description2Regular,
              ),
              const SizedBox(
                height: 4,
              ),
              Image.asset(
                _buildUrlStar(
                  completeCount: item.completeCount,
                  memberCount: item.memberCount,
                  isInactive: isAfterToday,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        isToday
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

  Widget _buildGroupOverviewInformationSection() {
    List<Widget> items = <Widget>[];
    for (int i = 0; i < numberOfDaysInAWeek; i++) {
      HabitGroupSummary item = sevenDaysInformation[i];
      items.add(
        _buildDailyRecapInformation(item),
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          child: Text(
            totalMembers == 1
                ? '$totalMembers member'
                : '$totalMembers members',
            style: QPTextStyle.subHeading4SemiBold.copyWith(
              color: QPColors.brandFair,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDetailNavigationCTA() {
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
                    groupName,
                    style: QPTextStyle.subHeading3SemiBold,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(
              color: QPColors.whiteSoft,
            ),
          ],
        ),
      ),
    );
  }
}
