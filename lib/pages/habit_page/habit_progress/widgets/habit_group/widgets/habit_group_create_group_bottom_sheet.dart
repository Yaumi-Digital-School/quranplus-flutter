import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/text_field.dart';

class HabitGroupCreateGroupBottomSheet {
  static void showModalCreateGroup({
    required BuildContext context,
    required Function(String) onSubmit,
  }) {
    String groupName = "";
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create habit group",
            style: QPTextStyle.subHeading2SemiBold,
          ),
          const SizedBox(height: 24),
          Text(
            "Input your group name",
            style: QPTextStyle.subHeading4Medium,
          ),
          const SizedBox(height: 8),
          FormFieldWidget(
            hintTextForm: "Input your group name",
            iconForm: const Icon(
              Icons.keyboard_outlined,
              size: 24,
              color: QPColors.blackFair,
            ),
            onChange: (String value) {
              groupName = value;
            },
          ),
          const SizedBox(height: 40),
          ButtonSecondary(
            label: "Create Group",
            onTap: () {
              onSubmit(groupName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
