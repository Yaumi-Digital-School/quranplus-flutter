import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/select_reciter_bottom_sheet/select_reciter_audio_preview_button.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/select_reciter_bottom_sheet/select_reciter_state_notifier.dart';

class SelectReciterRadioButton extends ConsumerStatefulWidget {
  const SelectReciterRadioButton({Key? key}) : super(key: key);

  @override
  ConsumerState<SelectReciterRadioButton> createState() =>
      _RadioButtonSelectReciterWidgetState();
}

class _RadioButtonSelectReciterWidgetState
    extends ConsumerState<SelectReciterRadioButton> {
  int playedId = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ButtonAudioState> buttonState =
        ref.watch(buttonAudioStateProvider);
    SelectReciterBottomSheetState selectReciter =
        ref.watch(selectReciterBottomSheetProvider);

    return ListView.builder(
      itemCount: selectReciter.listReciter.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final ReciterItemResponse item = selectReciter.listReciter[index];

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
                  child: RadioListTile<int>(
                    value: item.id,
                    groupValue: selectReciter.reciterId,
                    activeColor: QPColors.getColorBasedTheme(
                      dark: QPColors.brandFair,
                      light: QPColors.brandFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(selectReciterBottomSheetProvider.notifier)
                            .updateRadioButton(
                              value,
                              item.name,
                            );
                      }
                    },
                    title: Text(
                      item.name,
                      style: QPTextStyle.getSubHeading3Medium(context),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: buttonState.when(
                  data: (data) {
                    IconData icon =
                        item.id == playedId && data != ButtonAudioState.stop
                            ? Icons.pause
                            : Icons.play_arrow;

                    return InkWell(
                      onTap: _onTapAudioPreviewReciter(
                        data,
                        selectReciter,
                        index,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SelectReciterAudioPreviewButton(
                          icon: icon,
                        ),
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

  _onTapAudioPreviewReciter(
    data,
    SelectReciterBottomSheetState selectReciter,
    int index,
  ) {
    return () async {
      if (data == ButtonAudioState.paused || data == ButtonAudioState.stop) {
        ref.read(audioRecitationProvider.notifier).stopAndResetAudioPlayer();
        playedId = 0;
        await ref
            .read(selectReciterBottomSheetProvider.notifier)
            .playPreviewAudio(
              selectReciter.listReciter[index].id,
            );

        playedId = selectReciter.listReciter[index].id;

        return;
      }
      ref.read(audioRecitationProvider.notifier).pauseAudio();

      playedId = 0;
    };
  }
}
