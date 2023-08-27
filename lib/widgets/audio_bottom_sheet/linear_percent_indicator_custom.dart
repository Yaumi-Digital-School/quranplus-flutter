import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';

class LinearPercentIndicatorCustom extends ConsumerWidget {
  const LinearPercentIndicatorCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Duration> currentDuration =
        ref.watch(currentDurationProvider);
    final AsyncValue<Duration?> totalDuration =
        ref.watch(totalDurationProvider);
    final AudioHandler _audioHandler = ref.watch(audioHandler);

    return ProgressBar(
      baseBarColor: QPColors.brandRoot,
      progressBarColor: QPColors.brandFair,
      thumbRadius: 0,
      onSeek: ((Duration value) {
        _audioHandler.seek(value);
      }),
      timeLabelTextStyle: QPTextStyle.getDescription2Regular(context),
      progress: currentDuration.when(
        data: (data) => data,
        error: (error, st) => Duration.zero,
        loading: () => Duration.zero,
      ),
      total: totalDuration.when(
        data: (data) {
          if (data != null) return data;

          return Duration.zero;
        },
        error: (error, st) => Duration.zero,
        loading: () => Duration.zero,
      ),
    );
  }
}
