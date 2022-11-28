import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
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
    final String userName = sharedPreferenceService.getUsername();
    final String titleText = isComplete ? 'Awesome!' : 'Good Job!';
    final String titleIcon =
        isComplete ? ImagePath.partyPopper : ImagePath.emojiClap;
    final String subtitleText = isComplete
        ? 'Alhamdulillah, $userName!\nYou have reached your target!'
        : 'Good Job, $userName!\nJust a little more to reach your target';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          content: Column(
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
                    style: titleDialog,
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
              ButtonSecondary(
                label: "View Today's Progress",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(
                    context,
                    SuratPageV3OnPopParam(
                      nextNavigationBarIndex: 1,
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
