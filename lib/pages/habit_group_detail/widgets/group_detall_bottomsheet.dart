import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/snackbar.dart';

class HabitGroupBottomSheet {
  static void showModalInviteMemberGroup({
    required BuildContext context,
  }) {
    final TextEditingController _textController =
        TextEditingController(text: "Https://@gmail.com");

    // This function is triggered when the copy icon is pressed
    Future<void> _copyToClipboard() async {
      await Clipboard.setData(ClipboardData(text: _textController.text));
      Navigator.pop(context);
      GeneralSnackBar.showModalSnackBar(
        context: context,
        text: "Group link successfully copied",
      );
    }

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invite Member",
            style: QPTextStyle.subHeading2SemiBold,
          ),
          const SizedBox(height: 8),
          Text(
            "Copy this link and send it to the people you want to join  ",
            style: QPTextStyle.body3Regular,
          ),
          Text(
            "Group Ngaji Alfatonah",
            style: QPTextStyle.body3SemiBold,
          ),
          const SizedBox(height: 24),
          TextField(
            readOnly: true,
            style: QPTextStyle.subHeading3Regular,
            controller: _textController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              fillColor: QPColors.whiteRoot,
              suffixIconColor: QPColors.blackHeavy,
              suffixIcon: IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
              ),
            ),
          ),
          const SizedBox(height: 53),
        ],
      ),
    );
  }

  static void showModalLeaveGroup({
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
                size: ButtonSize.regular,
                textStyle: QPTextStyle.button1SemiBold
                    .copyWith(color: QPColors.whiteMassive),
              ),
              ButtonSecondary(
                label: 'Leave',
                onTap: () {},
                size: ButtonSize.regular,
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
