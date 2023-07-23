import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

final currentDurationProvider = StreamProvider.autoDispose<Duration>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  return audioPlayer.positionStream;
});

final totalDurationProvider = StreamProvider.autoDispose<Duration?>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  return audioPlayer.durationStream;
});

final buttonAudioStateProvider =
    StreamProvider.autoDispose<ButtonAudioState>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  return audioPlayer.playerStateStream.map((event) {
    final isPlaying = event.playing;
    final processingState = event.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return ButtonAudioState.loading;
    } else if (!isPlaying || processingState == ProcessingState.completed) {
      return ButtonAudioState.paused;
    } else {
      return ButtonAudioState.playing;
    }
  });
});
