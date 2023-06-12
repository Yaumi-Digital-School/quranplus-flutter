import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:intl/intl.dart';

class DailyProgressTracker extends StatelessWidget {
  const DailyProgressTracker({
    Key? key,
    required this.target,
    required this.dailyProgress,
    required this.isNeedSync,
  }) : super(key: key);

  final int target;
  final int dailyProgress;
  final bool isNeedSync;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);

    int dailyProgressToInt = dailyProgress.floor();
    double progress = dailyProgress / target;
    if (progress > 1) {
      progress = 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Today's Progress",
          style: QPTextStyle.getSubHeading1SemiBold(context),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          formattedDate,
          style: QPTextStyle.getSubHeading4Medium(context).copyWith(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.whiteRoot,
              light: QPColors.blackFair,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        SizedBox(
          width: double.infinity,
          child: LinearPercentIndicator(
            animation: true,
            lineHeight: 16.0,
            animationDuration: 1000,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            percent: progress,
            barRadius: const Radius.circular(8),
            progressColor: QPColors.brandFair,
            backgroundColor: QPColors.brandRoot,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            target > 1
                ? '$dailyProgressToInt / $target pages'
                : '$dailyProgressToInt / $target page',
            style: QPTextStyle.getSubHeading4Regular(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteRoot,
                light: QPColors.blackFair,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ),
        ),
        if (isNeedSync)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "*back online within 7 days to sync your data",
              style: QPTextStyle.getDescription2Regular(context),
            ),
          ),
      ],
    );
  }
}
