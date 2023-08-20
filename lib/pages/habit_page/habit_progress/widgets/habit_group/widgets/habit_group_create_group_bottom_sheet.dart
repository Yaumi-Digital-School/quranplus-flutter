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
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String groupName = "";

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create habit group",
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          const SizedBox(height: 24),
          Text(
            "Input your group name",
            style: QPTextStyle.getSubHeading4Medium(context),
          ),
          const SizedBox(height: 8),
          Form(
            key: formKey,
            child: FormFieldWidget(
              hintTextForm: "Input your group name",
              iconForm: const Icon(
                Icons.keyboard_outlined,
                size: 24,
                color: QPColors.blackFair,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Group name can't be empty!";
                }

                return null;
              },
              onChange: (String value) {
                groupName = value;
              },
            ),
          ),
          const SizedBox(height: 40),
          ButtonSecondary(
            label: "Save",
            onTap: () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              onSubmit(groupName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
