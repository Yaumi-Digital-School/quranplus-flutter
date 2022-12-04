import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/animation_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class HabitProgressPostTrackingDialog {
  static void onSubmitPostTrackingDialog({
    required BuildContext context,
    required SharedPreferenceService sharedPreferenceService,
    required bool isComplete,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          content: _PostSubmissionRemarks(
            sharedPreferenceService: sharedPreferenceService,
            isComplete: isComplete,
            cta: ButtonSecondary(
              label: "View Today's Progress",
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                final BottomNavigationBar navbar =
                    MainPage.globalKey.currentWidget as BottomNavigationBar;
                navbar.onTap!(1);
              },
            ),
          ),
        );
      },
    );
  }

  static void onTapBackTrackingDialog({
    required BuildContext context,
    required SharedPreferenceService sharedPreferenceService,
    required bool isComplete,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          content: _PostSubmissionRemarks(
            sharedPreferenceService: sharedPreferenceService,
            isComplete: isComplete,
            cta: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ButtonNeutral(
                  size: ButtonSize.small,
                  label: 'View Progress',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    final BottomNavigationBar navbar =
                        MainPage.globalKey.currentWidget as BottomNavigationBar;
                    navbar.onTap!(1);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                ButtonSecondary(
                  size: ButtonSize.small,
                  label: 'Back to Homepage',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(
                      context,
                      SuratPageV3OnPopParam(
                        isHabitDailySummaryChanged: true,
                      ),
                    );
                    final BottomNavigationBar navbar =
                        MainPage.globalKey.currentWidget as BottomNavigationBar;
                    navbar.onTap!(0);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostSubmissionRemarks extends StatelessWidget {
  const _PostSubmissionRemarks({
    Key? key,
    required this.sharedPreferenceService,
    required this.cta,
    this.isComplete = false,
  }) : super(key: key);

  final SharedPreferenceService sharedPreferenceService;
  final bool isComplete;
  final Widget cta;

  @override
  Widget build(BuildContext context) {
    final String userName = sharedPreferenceService.getUsername();
    final String titleText = isComplete ? 'Awesome!' : 'Good Job!';
    final String titleIcon =
        isComplete ? ImagePath.partyPopper : ImagePath.emojiClap;
    final String subtitleText = isComplete
        ? 'Alhamdulillah, $userName!\nYou have reached your target!'
        : 'Good Job, $userName!\nJust a little more to reach your target';

    return Stack(
      children: [
        Lottie.asset(AnimationPaths.confettiLive),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  titleIcon,
                  height: 20,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  titleText,
                  style: buildTextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 21,
            ),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: buildTextStyle(
                color: neutral700,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 43,
            ),
            cta,
          ],
        ),
      ],
    );
  }
}
