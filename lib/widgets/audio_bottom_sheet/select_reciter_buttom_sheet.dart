import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_widget.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/radio_button_change_reciter.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class SelectRecitatorWidget extends ConsumerStatefulWidget {
  const SelectRecitatorWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectRecitatorWidget> createState() =>
      _SelectRecitatorWidgetState();
}

class _SelectRecitatorWidgetState extends ConsumerState<SelectRecitatorWidget> {
  @override
  Widget build(BuildContext context) {
    final SelectReciterBottomSheetState selectReciterState =
        ref.watch(selectReciterBottomSheetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Reciter",
          style: QPTextStyle.getSubHeading2SemiBold(context),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          "Select available reciter for audio recitation",
          style: QPTextStyle.getBody3Regular(context),
        ),
        const SizedBox(
          height: 24,
        ),
        const RadioButtonSelectReciter(),
        const SizedBox(
          height: 16,
        ),
        ButtonSecondary(
          label: "Save",
          onTap: _onTapSaveReciterOption(selectReciterState),
        ),
      ],
    );
  }

  _onTapSaveReciterOption(
    SelectReciterBottomSheetState selectReciterState,
  ) {
    return () async {
      ref.read(audioRecitationProvider.notifier).pauseAudio();
      await ref.read(selectReciterBottomSheetProvider.notifier).saveDataReciter(
            selectReciterState.reciterId!,
            selectReciterState.reciterName!,
          );

      await ref
          .read(selectReciterBottomSheetProvider.notifier)
          .backToAudioBottomSheet(
            selectReciterState.reciterId!,
            selectReciterState.reciterName!,
            ref.watch(audioRecitationProvider.notifier),
          );

      Navigator.pop(context);
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const AudioBottomSheetWidget(),
      );
    };
  }
}
