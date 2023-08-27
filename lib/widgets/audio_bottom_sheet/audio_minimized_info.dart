import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_minimized_info_icon_button.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';

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
  late AudioRecitationStateNotifier audioPlayerNotifier;

  @override
  void initState() {
    audioPlayerNotifier = ref.read(audioRecitationProvider.notifier);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AudioRecitationState audioPlayerState =
        ref.watch(audioRecitationProvider);

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
            const Padding(
              padding: EdgeInsets.all(16),
              child: AudioMinimizedInfoIconButton(),
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
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.blackMassive,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
