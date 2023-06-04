import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:version/version.dart';

class OptionalUpdateDialog extends ConsumerWidget {
  const OptionalUpdateDialog({
    Key? key,
    required this.optionalMinVersion,
  }) : super(key: key);

  final Version optionalMinVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'New update available!',
            style: QPTextStyle.subHeading2SemiBold,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'To improve your experience, we recommend\nto update the app.',
            textAlign: TextAlign.center,
            style: QPTextStyle.body3Medium,
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
          const SizedBox(
            height: 12,
          ),
          ButtonPrimary(
            label: 'No, Later',
            onTap: () {
              SharedPreferenceService sharedpref =
                  ref.read(sharedPreferenceServiceProvider);

              sharedpref.setShownOptionalUpdateMinVersion(
                optionalMinVersion.toString(),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
