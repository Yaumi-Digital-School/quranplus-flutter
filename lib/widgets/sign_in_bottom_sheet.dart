import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class SignInBottomSheet {
  static void showAccountDeletedInfo({
    required BuildContext context,
  }) {
    return GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sorry, we can’t register your\naccount! :(',
            textAlign: TextAlign.center,
            style: QPTextStyle.getSubHeading1SemiBold(context),
          ),
          const SizedBox(
            height: 16,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  'Your email is associated with another account. Please reach us at',
              style: QPTextStyle.getBody2Regular(context).copyWith(
                // Todo: check color based on theme
                color: QPColors.blackHeavy,
              ),
              children: [
                TextSpan(
                  text: ' yaumi.indonesia@gmail.com ',
                  style: QPTextStyle.getBody2Regular(context),
                ),
                TextSpan(
                  text: 'and',
                  style: QPTextStyle.getBody2Regular(context).copyWith(
                    // Todo: check color based on theme
                    color: QPColors.blackHeavy,
                  ),
                ),
                TextSpan(
                  text: ' rizaherzego@gmail.com ',
                  style: QPTextStyle.getBody2Regular(context),
                ),
                TextSpan(
                  text: 'to proceed your registration with that account.',
                  style: QPTextStyle.getBody2Regular(context).copyWith(
                    // Todo: check color based on theme
                    color: QPColors.blackHeavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          ButtonPrimary(
            label: 'OK',
            onTap: () => Navigator.pop(context),
            size: ButtonSize.regular,
          ),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required VoidCallback onTapSignInWithGoogle,
    required VoidCallback onTapSignInWithApple,
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
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in or create account to access your group invitation',
            style: QPTextStyle.getBody3Regular(context),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ButtonSecondary(
              label: 'Sign In with Google',
              onTap: onTapSignInWithGoogle,
              leftIcon: StoredIcon.iconGoogle.path,
            ),
          ),
          const SizedBox(height: 16),
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ButtonSecondary(
                label: 'Sign In with Apple',
                onTap: onTapSignInWithApple,
                leftIcon: StoredIcon.iconGoogle.path,
              ),
            ),
        ],
      ),
    );
  }
}
