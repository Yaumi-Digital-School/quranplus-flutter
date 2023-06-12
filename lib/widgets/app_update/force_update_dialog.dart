import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:store_redirect/store_redirect.dart';

class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      backgroundColor: QPColors.whiteFair,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            ImagePath.forceUpdateIcon,
          ),
          const SizedBox(
            height: 28,
          ),
          Text(
            '📣 Update Required!',
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Stay up-to-date with the latest\nfeatures and security updates.',
            textAlign: TextAlign.center,
            style: QPTextStyle.getBody3Medium(context),
          ),
          const SizedBox(
            height: 28,
          ),
          ButtonSecondary(
            label: 'Update',
            onTap: () {
              StoreRedirect.redirect(
                androidAppId: EnvConstants.appPackageName,
                iOSAppId: EnvConstants.appAppstoreID,
              );
            },
          ),
        ],
      ),
    );
  }
}
