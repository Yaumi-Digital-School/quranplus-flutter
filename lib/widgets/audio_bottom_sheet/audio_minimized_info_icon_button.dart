import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';

class AudioMinimizedInfoIconButton extends ConsumerWidget {
  const AudioMinimizedInfoIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: _IconButton(
            icon: buttonState.value == ButtonAudioState.paused
                ? Icons.play_arrow
                : Icons.pause,
          ),
        );
      },
      error: (_, __) {
        return const SizedBox.shrink();
      },
      loading: () {
        return _IconButton(
          icon: buttonState.value == ButtonAudioState.paused
              ? Icons.play_arrow
              : Icons.pause,
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    Key? key,
    required this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
