import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';

class AudioRecitationGeneralService {
  AudioRecitationGeneralService({
    required this.audioApi,
    required this.audioHandler,
  });

  final AudioApi audioApi;
  final AudioRecitationHandler audioHandler;
  StreamSubscription<PlayerState>? playerStateSubscription;

  void play() {
    audioHandler.play();
  }

  void pause() {
    audioHandler.pause();
  }

  void stop() {
    audioHandler.stop();
  }
}
