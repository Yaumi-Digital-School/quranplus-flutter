import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';

final Provider<AudioPlayer> audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

final AutoDisposeStreamProvider<Duration> currentDurationProvider =
    StreamProvider.autoDispose<Duration>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  return audioPlayer.positionStream;
});

final AutoDisposeStreamProvider<Duration?> totalDurationProvider =
    StreamProvider.autoDispose<Duration?>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);

  return audioPlayer.durationStream;
});

final AutoDisposeStreamProvider<ButtonAudioState> buttonAudioStateProvider =
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

final Provider<AudioApi> audioApiProvider = Provider<AudioApi>((ref) {
  final DioService dioService = ref.watch(dioServiceProvider);

  return AudioApi(
    dioService.getDioWithAccessToken(),
  );
});
