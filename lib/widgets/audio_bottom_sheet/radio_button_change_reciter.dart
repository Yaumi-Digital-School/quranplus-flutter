import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';

class RadioButtonSelectReciter extends ConsumerStatefulWidget {
  const RadioButtonSelectReciter({Key? key}) : super(key: key);

  @override
  ConsumerState<RadioButtonSelectReciter> createState() =>
      _RadioButtonSelectReciterWidgetState();
}

class _RadioButtonSelectReciterWidgetState
    extends ConsumerState<RadioButtonSelectReciter> {
  late SelectReciterStateNotifier selectReciterNotifier;

  @override
  void initState() {
    selectReciterNotifier = ref.read(selectReciterBottomSheetProvider.notifier);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ButtonAudioState> buttonState =
        ref.watch(buttonAudioStateProvider);
    SelectReciterBottomSheetState selectReciter =
        ref.watch(selectReciterBottomSheetProvider);

    return SizedBox(
      height: 258,
      child: ListView.builder(
        itemCount: selectReciter.listReciter.length,
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
                      value: selectReciter.listReciter[index].id,
                      groupValue: selectReciter.reciterId,
                      onChanged: (value) {
                        setState(() {
                          selectReciter.reciterId = value;
                          selectReciter.reciterName =
                              selectReciter.listReciter[index].name;
                        });
                      },
                      title: Text(
                        selectReciter.listReciter[index].name,
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
                            ref
                                .read(audioRecitationProvider.notifier)
                                .stopAndResetAudioPlayer();
                            await ref
                                .read(selectReciterBottomSheetProvider.notifier)
                                .playPreviewAudio(
                                  selectReciter.listReciter[index].id,
                                );

                            return;
                          }
                          ref
                              .read(audioRecitationProvider.notifier)
                              .pauseAudio();
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
      ),
    );
  }
}
