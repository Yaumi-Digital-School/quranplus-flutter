import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/button_audio_enum.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';

final Provider<AudioRecitationHandler> audioHandler =
    Provider<AudioRecitationHandler>((ref) {
  return AudioRecitationHandler();
});

final AutoDisposeStreamProvider<Duration> currentDurationProvider =
    StreamProvider.autoDispose<Duration>((ref) {
  final AudioRecitationHandler _audioHandler = ref.watch(audioHandler);

  return _audioHandler.getPositionStream();
});

final AutoDisposeStreamProvider<Duration?> totalDurationProvider =
    StreamProvider.autoDispose<Duration?>((ref) {
  final AudioRecitationHandler _audioHandler = ref.watch(audioHandler);

  return _audioHandler.getDurationStream();
});

final AutoDisposeStreamProvider<ButtonAudioState> buttonAudioStateProvider =
    StreamProvider.autoDispose<ButtonAudioState>((ref) {
  final AudioRecitationHandler _audioHandler = ref.watch(audioHandler);

  return _audioHandler.getPlayerStateStream().map((event) {
    final isPlaying = event.playing;
    final processingState = event.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return ButtonAudioState.loading;
    } else if (!isPlaying && processingState == ProcessingState.idle) {
      return ButtonAudioState.stop;
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
