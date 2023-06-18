import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/animation_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

import 'package:qurantafsir_flutter/widgets/button.dart';

class PreHabitTrackingAnimation extends StatefulWidget {
  const PreHabitTrackingAnimation({Key? key, required this.notifier})
      : super(key: key);
  final SuratPageStateNotifier notifier;

  @override
  State<PreHabitTrackingAnimation> createState() =>
      _PreHabitTrackingAnimationState();
}

class _PreHabitTrackingAnimationState extends State<PreHabitTrackingAnimation> {
  Timer? timer;
  @override
  void initState() {
    super.initState();

    timer = Timer(
      const Duration(seconds: 6),
      () {
        Navigator.pop(
          context,
        );
        widget.notifier.startRecording();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: OrientationBuilder(
      builder: (context, orientation) {
        return Center(
          child: orientation == Orientation.portrait
              ? _buildPotraitOrientation()
              : _buildLandscapeOrientation(),
        );
      },
    ));
  }

  Widget _buildPotraitOrientation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Take a breath',
          style: QPTextStyle.getHeading1Bold(context),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "Start with Basmalah",
          style: QPTextStyle.getSubHeading1Regular(context),
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
          style: QPTextStyle.getSubHeading1Regular(context).copyWith(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.whiteRoot,
              light: QPColors.blackFair,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
        ),
        const SizedBox(
          height: 84,
        ),
        ButtonPill(
          onTap: () {
            Navigator.pop(context);
            timer?.cancel();
          },
          label: "Cancel Tracking",
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildLandscapeOrientation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 18,
        ),
        Text(
          'Take a breath',
          style: QPTextStyle.getHeading1Bold(context),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          "Start with Basmalah",
          style: QPTextStyle.getSubHeading1Regular(context),
        ),
        const Spacer(),
        Lottie.asset(
          AnimationPaths.takingBreathe,
          width: 198,
        ),
        const Spacer(),
        Text(
          "Prepare for reading....",
          style: QPTextStyle.getSubHeading1Regular(context).copyWith(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.whiteRoot,
              light: QPColors.blackFair,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
        ),
        const SizedBox(
          height: 9,
        ),
        ButtonPill(
          onTap: () {
            Navigator.pop(context);
            timer?.cancel();
          },
          label: "Cancel Tracking",
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }
}
