import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/animation_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/adaptive_theme_dialog.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

class HabitProgressPostTrackingDialog {
  static void onSubmitPostTrackingDialog({
    required BuildContext context,
    required SharedPreferenceService sharedPreferenceService,
    required bool isComplete,
  }) {
    showQPGeneralDialog(
      context: context,
      builder: (context) {
        return AdaptiveThemeDialog(
          contentPadding: const EdgeInsets.fromLTRB(
            24.0,
            20.0,
            24.0,
            24.0,
          ),
          borderRadiusValue: 19,
          child: _PostSubmissionRemarks(
            sharedPreferenceService: sharedPreferenceService,
            isComplete: isComplete,
            cta: ButtonSecondary(
              label: "View Today's Progress",
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                final BottomNavigationBar navbar =
                    mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
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
    showQPGeneralDialog(
      context: context,
      builder: (context) {
        return AdaptiveThemeDialog(
          child: _PostSubmissionRemarks(
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
                    final BottomNavigationBar navbar = mainNavbarGlobalKey
                        .currentWidget as BottomNavigationBar;
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
                    final BottomNavigationBar navbar = mainNavbarGlobalKey
                        .currentWidget as BottomNavigationBar;
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
                  style: QPTextStyle.getSubHeading2Medium(context),
                ),
              ],
            ),
            const SizedBox(
              height: 21,
            ),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: QPTextStyle.getBody3Regular(context),
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
