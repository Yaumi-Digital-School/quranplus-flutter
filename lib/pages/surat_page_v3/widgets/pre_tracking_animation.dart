import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:qurantafsir_flutter/shared/constants/animation_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class PreHabitTrackingAnimation extends StatelessWidget {
  const PreHabitTrackingAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Ready',
              style: buildTextStyle(
                color: neutral900,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Don't forget to say Basmalah",
              style: buildTextStyle(
                color: neutral900,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Lottie.asset(
              AnimationPaths.takingBreathe,
              width: 297,
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Prepare for reading....",
              style: buildTextStyle(
                color: neutral600,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
