import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
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
          style: TextStyle(fontSize: 17, fontWeight: semiBold),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          formattedDate,
          style:
              TextStyle(fontSize: 12, color: Colors.grey, fontWeight: medium),
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
            progressColor: darkGreen,
            backgroundColor: neutral300,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            target > 1
                ? '$dailyProgressToInt / $target pages'
                : '$dailyProgressToInt / $target page',
            style:
                TextStyle(fontSize: 12, fontWeight: regular, color: neutral600),
          ),
        ),
        if (isNeedSync)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "*back online within 7 days to sync your data",
              style: regular10.copyWith(color: neutral600),
            ),
          ),
      ],
    );
  }
}
