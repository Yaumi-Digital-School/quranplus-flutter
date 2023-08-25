import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/select_reciter_buttom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/linear_percent_indicator_custom.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

class AudioBottomSheetWidget extends ConsumerStatefulWidget {
  const AudioBottomSheetWidget({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<AudioBottomSheetWidget> createState() =>
      _AudioBottomSheetWidgetState();
}

class _AudioBottomSheetWidgetState
    extends ConsumerState<AudioBottomSheetWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ButtonAudioState> buttonState =
        ref.watch(buttonAudioStateProvider);

    final AudioRecitationState audioBottomSheetState =
        ref.watch(audioRecitationProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  audioBottomSheetState.surahName,
                  style: QPTextStyle.getSubHeading3SemiBold(context),
                ),
                Text(
                  "Ayah ${audioBottomSheetState.ayahId}",
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
          child: Stack(
            children: [
              if (audioBottomSheetState.surahId > 1)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 25),
                    child: _buildPreviousSurahCTA(
                      surahNumberToSurahNameMap[
                              audioBottomSheetState.surahId - 1]
                          .toString(),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: buttonState.when(
                  data: (data) {
                    if (data == ButtonAudioState.loading ||
                        audioBottomSheetState.isLoading) {
                      return const SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(),
                      );
                    }

                    return InkWell(
                      onTap: () {
                        if (data == ButtonAudioState.paused) {
                          ref
                              .read(audioRecitationProvider.notifier)
                              .playAudio();

                          return;
                        }
                        ref.read(audioRecitationProvider.notifier).pauseAudio();
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
              ),
              if (audioBottomSheetState.surahId < 114)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, right: 25),
                    child: _buildNextSurahCTA(
                      surahNumberToSurahNameMap[
                              audioBottomSheetState.surahId + 1]
                          .toString(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            ref.read(audioRecitationProvider.notifier).changeReciter(
                  ref.read(selectReciterBottomSheetProvider.notifier),
                );
            ref.read(audioRecitationProvider.notifier).pauseAudio();

            Navigator.pop(context);
            GeneralBottomSheet.showBaseBottomSheet(
              context: context,
              isBarrierDismissable: false,
              isDraggable: false,
              widgetChild: const SelectRecitatorWidget(),
            );
          },
          child: Row(
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
                    audioBottomSheetState.reciterName ?? '',
                    style: QPTextStyle.getBody2Medium(context),
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 24,
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteFair,
                  light: QPColors.blackFair,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextSurahCTA(String title) {
    return InkWell(
      onTap: () {
        ref.read(audioRecitationProvider.notifier).nextSurah();
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 100,
        ),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: QPColors.getColorBasedTheme(
            dark: QPColors.blackHeavy,
            light: QPColors.whiteMassive,
            brown: QPColors.brownModeSoft,
            context: context,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.skip_next,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                title,
                style: QPTextStyle.getBody2Medium(context),
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousSurahCTA(String title) {
    return InkWell(
      onTap: () {
        ref.read(audioRecitationProvider.notifier).previousSurah();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          maxWidth: 100,
        ),
        decoration: BoxDecoration(
          color: QPColors.getColorBasedTheme(
            dark: QPColors.blackHeavy,
            light: QPColors.whiteMassive,
            brown: QPColors.brownModeSoft,
            context: context,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: QPTextStyle.getBody2Medium(context),
                overflow: TextOverflow.fade,
                textAlign: TextAlign.right,
                softWrap: false,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.skip_previous,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
