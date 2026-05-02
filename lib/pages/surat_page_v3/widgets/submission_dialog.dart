import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/post_tracking_dialog.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/widgets/adaptive_theme_dialog.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class TrackingSubmissionDialog extends StatefulWidget {
  const TrackingSubmissionDialog({
    super.key,
    this.isFromTapBack = false,
    required this.habitNotifier,
  });

  final bool isFromTapBack;
  final SuratPageHabitNotifier habitNotifier;

  @override
  State<TrackingSubmissionDialog> createState() =>
      _TrackingSubmissionDialogState();
}

class _TrackingSubmissionDialogState extends State<TrackingSubmissionDialog> {
  bool isLoading = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.habitNotifier.recordedPagesList.length.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveThemeDialog(
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      borderRadiusValue: 19,
      child: isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
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
                  style: QPTextStyle.getSubHeading3Medium(context),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInput(),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 24),
                ButtonSecondary(
                  label: 'Submit',
                  onTap: () async {
                    setState(() => isLoading = true);

                    final int pages =
                        int.tryParse(_controller.text) ?? 0;
                    final bool isComplete =
                        await widget.habitNotifier.stopRecording(pages);

                    if (context.mounted) {
                      Navigator.pop(context);

                      if (widget.isFromTapBack) {
                        HabitProgressPostTrackingDialog.onTapBackTrackingDialog(
                          context: context,
                          sharedPreferenceService:
                              widget.habitNotifier.sharedPreferenceService,
                          isComplete: isComplete,
                        );
                        return;
                      }

                      HabitProgressPostTrackingDialog
                          .onSubmitPostTrackingDialog(
                        context: context,
                        sharedPreferenceService:
                            widget.habitNotifier.sharedPreferenceService,
                        isComplete: isComplete,
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildInput() {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controller,
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
