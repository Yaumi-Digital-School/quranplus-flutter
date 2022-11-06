import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class DailyProgressTracker extends StatelessWidget {
  const DailyProgressTracker({
    Key? key,
    required this.target,
    required this.dailyProgress,
  }) : super(key: key);

  final int target;
  final double dailyProgress;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);

    int dailyProgressToInt = dailyProgress.floor();

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
            percent: dailyProgress / target,
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
      ],
    );
  }
}
