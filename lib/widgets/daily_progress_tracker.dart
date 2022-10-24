import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class DailyProgresTracker extends StatelessWidget {
  const DailyProgresTracker({
    Key? key,
    required this.target,
    required this.dailyProgres,
  });

  final int target;
  final double dailyProgres;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);

    int dailyProgressToInt = dailyProgres.round();

    return Card(
      color: Colors.white,
      elevation: 1.2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 176,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 17, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Today's Progress",
                style: TextStyle(fontSize: 17, fontWeight: semiBold),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                formattedDate,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey, fontWeight: medium),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: LinearPercentIndicator(
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 2500,
                  percent: dailyProgres / target,
                  barRadius: Radius.circular(9),
                  progressColor: darkGreen,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 10, 5),
                alignment: Alignment.centerRight,
                child: Text(
                  target > 1
                      ? '$dailyProgressToInt / $target pages'
                      : '$dailyProgressToInt / $target page',
                  style: TextStyle(
                      fontSize: 12, fontWeight: regular, color: neutral600),
                ),
              ),
              ButtonSecondary(label: 'See Detail', onTap: () {})
            ],
          ),
        ),
      ),
    );
  }
}
