import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/habit_progress_view.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/snackbar.dart';
import 'package:qurantafsir_flutter/widgets/text_field.dart';

class HabitGroupBottomSheet {
  static void showModalInviteMemberGroup({
    required BuildContext context,
    required String url,
    required String currentGroupName,
  }) {
    final TextEditingController textController =
        TextEditingController(text: url);

    // This function is triggered when the copy icon is pressed
    Future<void> copyToClipboard() async {
      await Clipboard.setData(ClipboardData(text: textController.text));
      if (context.mounted) {
        Navigator.pop(context);
        GeneralSnackBar.showModalSnackBar(
          context: context,
          text: "Group link successfully copied",
        );
      }
    }

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Invite Member",
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text:
                  'Copy this link and send it to the people you want to join ',
              style: QPTextStyle.getBody3Regular(context),
              children: [
                TextSpan(
                  text: currentGroupName,
                  style: QPTextStyle.getBody3SemiBold(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            readOnly: true,
            style: QPTextStyle.getSubHeading3Regular(context).copyWith(
              color: QPColors.blackMassive,
            ),
            controller: textController,
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
                onPressed: copyToClipboard,
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
    String currentGroupName = '',
  }) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String groupName = currentGroupName;

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Edit group name",
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
              initialValue: groupName,
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

              GeneralSnackBar.showModalSnackBar(
                context: context,
                text: "Group name successfully saved",
              );
            },
          ),
        ],
      ),
    );
  }

  static void showModalLeaveGroup({
    required BuildContext context,
    required Future<void> Function() onTap,
    required WidgetRef ref,
    required HabitGroupDetailStateNotifier notifier,
  }) {
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Confirm leave group",
              style: QPTextStyle.getHeading1Regular(context),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Are you sure you want to leave group?",
              style: QPTextStyle.getSubHeading3Regular(context),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonPrimary(
                label: 'Cancel',
                onTap: () {
                  Navigator.pop(context);
                },
                size: ButtonSize.regular,
                textStyle: QPTextStyle.getButton1SemiBold(context)
                    .copyWith(color: QPColors.whiteMassive),
              ),
              ButtonSecondary(
                label: 'Leave',
                onTap: () async {
                  await onTap();
                  if (context.mounted) {
                    Navigator.pop(context);
                    final bool canPop = Navigator.canPop(context);

                    if (canPop) {
                      Navigator.pop(context, notifier.isLeaveGrup);

                      return;
                    }
                  }

                  const HabitProgressTab selectedTabOnPop =
                      HabitProgressTab.group;

                  ref
                      .read(mainPageProvider)
                      .setHabitGroupProgressSelectedTab(selectedTabOnPop);

                  if (context.mounted) {
                    Navigator.pushReplacementNamed(
                      context,
                      RoutePaths.routeMain,
                      arguments: MainPageParam(
                        initialSelectedIdx: selectedTabOnPop.index,
                      ),
                    );
                  }
                },
                size: ButtonSize.regular,
                textStyle: QPTextStyle.getButton1SemiBold(context)
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
            style: QPTextStyle.getHeading1SemiBold(context)
                .copyWith(color: QPColors.brandFair),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Now you can update and set your reading\nprogress and target with group members",
            style: QPTextStyle.getBody2Regular(context)
                .copyWith(color: QPColors.neutral700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ButtonSecondary(
            label: 'Close',
            onTap: () {
              Navigator.pop(context);
            },
            textStyle: QPTextStyle.getButton1SemiBold(context)
                .copyWith(color: QPColors.brandFair),
          ),
        ],
      ),
    );
  }
}
