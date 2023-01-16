import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class SignInBottomSheet {
  static void show({
    required BuildContext context,
    required VoidCallback onTapSignInWithGoogle,
    VoidCallback? onClose,
  }) {
    return GeneralBottomSheet.showBaseBottomSheet(
      onClose: onClose,
      context: context,
      widgetChild: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: QPColors.whiteSoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 20,
                color: QPColors.blackSoft,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign in Required',
            style: QPTextStyle.subHeading2SemiBold,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in or create account to access your group invitation',
            style: QPTextStyle.body3Regular,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 18,
            ),
            child: ButtonSecondary(
              label: 'Sign In with Google',
              onTap: onTapSignInWithGoogle,
              leftIcon: IconPath.iconGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
