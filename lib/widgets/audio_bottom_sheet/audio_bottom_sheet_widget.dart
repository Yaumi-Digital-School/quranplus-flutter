import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/linear_percent_indicator_custom.dart';

class AudioBottomSheetWidget extends ConsumerStatefulWidget {
  const AudioBottomSheetWidget({
    required this.surahName,
    required this.surahId,
    required this.ayahId,
    Key? key,
  }) : super(key: key);
  final String surahName;
  final int surahId;
  final int ayahId;
  @override
  ConsumerState<AudioBottomSheetWidget> createState() =>
      _AudioBottomSheetWidgetState();
}

class _AudioBottomSheetWidgetState
    extends ConsumerState<AudioBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final buttonState = ref.watch(buttonAudioStateProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.surahName,
                  style: QPTextStyle.getSubHeading3SemiBold(context),
                ),
                Text(
                  "Ayah ${widget.ayahId}",
                  style: QPTextStyle.getDescription2Regular(context),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 20),
        const LinearPercentIndicatorCustom(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Spacer(),
              buttonState.when(
                data: (data) {
                  if (data == ButtonAudioState.loading) {
                    return const SizedBox(
                      height: 36,
                      width: 36,
                      child: CircularProgressIndicator(),
                    );
                  }

                  return InkWell(
                    onTap: () {
                      if (data == ButtonAudioState.paused) {
                        audioPlayer.setUrl(
                          "https://verses.quran.com/AbdulBaset/Mujawwad/mp3/001001.mp3",
                        );
                        audioPlayer.play();

                        return;
                      }
                      audioPlayer.stop();
                    },
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: const BoxDecoration(
                        color: QPColors.brandFair,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          data == ButtonAudioState.paused
                              ? Icons.play_arrow
                              : Icons.pause,
                          color: Colors.white,
                          size: 20,
                        ),
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
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: QPColors.whiteFair,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.skip_next,
                              size: 20,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "Al-Baqarah",
                              style: QPTextStyle.getBody2Medium(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reciter",
                  style: QPTextStyle.getDescription2Regular(context),
                ),
                Text(
                  "Mishari Rashid al-`Afasy",
                  style: QPTextStyle.getBody2Medium(context),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_right, size: 24),
          ],
        ),
      ],
    );
  }
}
