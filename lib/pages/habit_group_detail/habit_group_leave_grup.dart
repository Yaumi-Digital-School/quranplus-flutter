import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class HabitGroupLeaveGroupBottomSheet {
  static void showModalCreateGroup({
    required BuildContext context,
  }) {
    // This function is triggered when the copy icon is pressed

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Confirm leave group",
              style: QPTextStyle.heading1Regular,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Are you sure you want to leave group?",
              style: QPTextStyle.subHeading3Regular,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonPrimary(
                label: 'cancel',
                onTap: () {
                  Navigator.pop(context);
                },
                size: ButtonSize.small,
                textStyle: QPTextStyle.button1SemiBold
                    .copyWith(color: QPColors.whiteMassive),
              ),
              ButtonSecondary(
                label: 'Leave',
                onTap: () {},
                size: ButtonSize.small,
                textStyle: QPTextStyle.button1SemiBold
                    .copyWith(color: QPColors.brandFair),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
