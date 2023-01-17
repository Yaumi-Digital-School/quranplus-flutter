import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/snackbar.dart';
import 'package:qurantafsir_flutter/widgets/text_field.dart';

class HabitGroupBottomSheet {
  static void showModalInviteMemberGroup({
    required BuildContext context,
    required String url,
  }) {
    final TextEditingController _textController =
        TextEditingController(text: url);

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
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
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

  static void showModalEditGroupName({
    required BuildContext context,
    required Function(String) onSubmit,
  }) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String groupName = "";

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Edit group name",
            style: QPTextStyle.subHeading2SemiBold,
          ),
          const SizedBox(height: 24),
          Text(
            "Input your group name",
            style: QPTextStyle.subHeading4Medium,
          ),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
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
              if (!_formKey.currentState!.validate()) {
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

  static void showModalLeaveGroup({
    required BuildContext context,
  }) {
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

  static void showModalSuccessJoinGroup({
    required BuildContext context,
  }) {
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: QPColors.brandFair,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Alhamdulillah, you joined the group!",
            style: QPTextStyle.heading1SemiBold
                .copyWith(color: QPColors.brandFair),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Now you can update and set your reading\nprogress and target with group members",
            style:
                QPTextStyle.body2Regular.copyWith(color: QPColors.neutral700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ButtonSecondary(
            label: 'Close',
            onTap: () {
              Navigator.pop(context);
            },
            textStyle:
                QPTextStyle.button1SemiBold.copyWith(color: QPColors.brandFair),
          ),
        ],
      ),
    );
  }
}
