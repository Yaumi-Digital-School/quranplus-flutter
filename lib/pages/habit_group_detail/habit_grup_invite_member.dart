import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class HabitGroupInviteMemberBottomSheet {
  static void showModalCreateGroup({
    required BuildContext context,
  }) {
    final TextEditingController _textController =
        TextEditingController(text: "Https://@gmail.com");

    // This function is triggered when the copy icon is pressed
    Future<void> _copyToClipboard() async {
      await Clipboard.setData(ClipboardData(text: _textController.text));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Group link successfully copied'),
      ));
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
          const SizedBox(height: 24),
          Text(
            "Copy this link and send it to the people you want to join  ",
            style: QPTextStyle.body3Regular,
          ),
          Text(
            "Group Ngaji Alfatanah",
            style: QPTextStyle.body3SemiBold,
          ),
          const SizedBox(height: 24),
          TextField(
            readOnly: true,
            controller: _textController,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: QPColors.whiteRoot,
              suffixIconColor: QPColors.blackHeavy,
              suffixIcon: IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
