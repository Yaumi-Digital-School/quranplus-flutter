import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_widget.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
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
    final AsyncValue<ButtonAudioState> buttonState =
        ref.watch(buttonAudioStateProvider);
    final SelectReciterBottomSheetState selectReciterState =
        ref.watch(selectReciterBottomSheetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 32,
        ),
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
        SizedBox(
          height: 258,
          child: _buildChangeReciterWidget(selectReciterState, buttonState),
        ),
        const SizedBox(
          height: 42,
        ),
        ButtonSecondary(
          label: "Save",
          onTap: () async {
            ref.read(audioRecitationProvider.notifier).pauseAudio();
            await ref
                .read(selectReciterBottomSheetProvider.notifier)
                .saveDataReciter(
                  selectReciterState.idReciter!,
                  selectReciterState.nameReciter!,
                );

            await ref
                .read(selectReciterBottomSheetProvider.notifier)
                .backToAudioBottomSheet(
                  selectReciterState.idReciter!,
                  selectReciterState.nameReciter!,
                  ref.watch(audioRecitationProvider.notifier),
                );

            Navigator.pop(context);
            GeneralBottomSheet.showBaseBottomSheet(
              context: context,
              widgetChild: const AudioBottomSheetWidget(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChangeReciterWidget(
    SelectReciterBottomSheetState state,
    final AsyncValue<ButtonAudioState> buttonState,
  ) {
    return ListView.builder(
      itemCount: state.listReciter.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: QPColors.getColorBasedTheme(
                      dark: QPColors.brandFair,
                      light: QPColors.brandFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                  child: RadioListTile<dynamic>(
                    value: state.listReciter[index].id,
                    groupValue: state.idReciter,
                    onChanged: (value) {
                      setState(() {
                        state.idReciter = value;
                        state.nameReciter = state.listReciter[index].name;
                      });
                    },
                    title: Text(
                      state.listReciter[index].name,
                      style: QPTextStyle.getSubHeading3Medium(context),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: buttonState.when(
                  data: (data) {
                    return InkWell(
                      onTap: () async {
                        if (data == ButtonAudioState.paused) {
                          int ayatIdPreview = 1;
                          ref
                              .read(audioRecitationProvider.notifier)
                              .stopAndResetAudioPlayer();
                          await ref
                              .read(selectReciterBottomSheetProvider.notifier)
                              .playPreviewAudio(
                                state.listReciter[index].id,
                                ayatIdPreview,
                              );

                          return;
                        }
                        ref.read(audioRecitationProvider.notifier).pauseAudio();
                      },
                      child: Icon(
                        data == ButtonAudioState.paused
                            ? Icons.play_circle_fill_rounded
                            : Icons.pause_circle_filled_rounded,
                        color: QPColors.getColorBasedTheme(
                          dark: QPColors.brandFair,
                          light: QPColors.brandFair,
                          brown: QPColors.brownModeMassive,
                          context: context,
                        ),
                        size: 20,
                      ),
                    );
                  },
                  error: (error, stacktrace) {
                    return Container();
                  },
                  loading: () => const SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
