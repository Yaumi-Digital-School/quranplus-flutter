import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_state_notifier.dart';

class AudioMinimizedInfo extends ConsumerStatefulWidget {
  const AudioMinimizedInfo({
    Key? key,
    required this.onClose,
    this.onTapContainer,
  }) : super(key: key);

  final VoidCallback onClose;
  final VoidCallback? onTapContainer;

  @override
  ConsumerState<AudioMinimizedInfo> createState() => _AudioMinimizedInfoState();
}

class _AudioMinimizedInfoState extends ConsumerState<AudioMinimizedInfo> {
  late AudioBottomSheetStateNotifier audioPlayerNotifier;

  @override
  void initState() {
    audioPlayerNotifier = ref.read(audioBottomSheetProvider.notifier);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AudioBottomSheetState audioPlayerState =
        ref.watch(audioBottomSheetProvider);

    return GestureDetector(
      onTap: widget.onTapContainer,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: QPColors.getColorBasedTheme(
            dark: QPColors.darkModeFair,
            light: QPColors.whiteFair,
            brown: QPColors.brownModeRoot,
            context: context,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildButton(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  audioPlayerState.surahName,
                  style: QPTextStyle.getSubHeading3SemiBold(context),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Ayah ${audioPlayerState.ayahId}',
                  style: QPTextStyle.getButton3SemiBold(context),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 24,
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    final AsyncValue<ButtonAudioState> buttonState =
        ref.watch(buttonAudioStateProvider);

    return buttonState.when(
      data: (data) {
        return InkWell(
          onTap: () {
            if (buttonState.value == ButtonAudioState.paused) {
              ref.read(audioBottomSheetProvider.notifier).playAudio();

              return;
            }
            ref.read(audioBottomSheetProvider.notifier).pauseAudio();
          },
          child: _buildIcon(
            buttonState.value == ButtonAudioState.paused
                ? Icons.play_arrow
                : Icons.pause,
          ),
        );
      },
      error: (_, __) {
        return const SizedBox.shrink();
      },
      loading: () {
        return _buildIcon(
          buttonState.value == ButtonAudioState.paused
              ? Icons.play_arrow
              : Icons.pause,
        );
      },
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      height: 36,
      width: 36,
      decoration: const BoxDecoration(
        color: QPColors.brandFair,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
