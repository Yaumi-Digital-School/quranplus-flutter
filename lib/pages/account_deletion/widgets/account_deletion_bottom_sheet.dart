import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class AccountDeletionBottomSheet {
  static void showDeletionConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Delete Confirmation',
            textAlign: TextAlign.center,
            style: QPTextStyle.subHeading1SemiBold,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Are you sure you want to delete your account?\nThis action can’t be undone.',
            textAlign: TextAlign.center,
            style: QPTextStyle.body2Regular.copyWith(
              color: QPColors.blackFair,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonPrimary(
                label: 'Cancel',
                onTap: () => Navigator.pop(context),
                size: ButtonSize.regular,
              ),
              const SizedBox(
                width: 16,
              ),
              ButtonSecondary(
                label: 'Delete',
                onTap: onConfirm,
                size: ButtonSize.regular,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
