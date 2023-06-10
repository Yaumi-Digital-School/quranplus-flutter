import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/post_tracking_dialog.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class TrackingSubmissionDialog extends StatefulWidget {
  const TrackingSubmissionDialog({
    Key? key,
    this.isFromTapBack = false,
    required this.notifier,
  }) : super(key: key);

  final bool isFromTapBack;
  final SuratPageStateNotifier notifier;

  @override
  State<TrackingSubmissionDialog> createState() =>
      _TrackingSubmissionDialogState();
}

class _TrackingSubmissionDialogState extends State<TrackingSubmissionDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: brokenWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(19)),
      ),
      content: isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  'Submitting...',
                  style: QPTextStyle.getSubHeading2Regular(context),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.isFromTapBack
                      ? 'Please submit your reading progress before back to the Homepage'
                      : "You've finished reading....",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: neutral900,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    _buildTrackerSubmissionDialogInput(widget.notifier),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'Pages',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: neutral600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                ButtonSecondary(
                  label: 'Submit',
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });

                    final bool isComplete =
                        await widget.notifier.stopRecording();
                    Navigator.pop(context);

                    if (widget.isFromTapBack) {
                      HabitProgressPostTrackingDialog.onTapBackTrackingDialog(
                        context: context,
                        sharedPreferenceService:
                            widget.notifier.sharedPreferenceService,
                        isComplete: isComplete,
                      );

                      return;
                    }

                    HabitProgressPostTrackingDialog.onSubmitPostTrackingDialog(
                      context: context,
                      sharedPreferenceService:
                          widget.notifier.sharedPreferenceService,
                      isComplete: isComplete,
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildTrackerSubmissionDialogInput(SuratPageStateNotifier notifier) {
    notifier.habitTrackerSubmissionController.value = TextEditingValue(
      text: notifier.recordedPagesList.length.toString(),
    );

    return SizedBox(
      width: 60,
      child: TextField(
        controller: notifier.habitTrackerSubmissionController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: neutral600,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.all(7),
          hintText: '1',
          hintStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: neutral400,
          ),
          border: enabledInputBorder,
          enabledBorder: enabledInputBorder,
          errorBorder: errorInputBorder,
          focusedErrorBorder: errorInputBorder,
        ),
      ),
    );
  }
}
