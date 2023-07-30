import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';

@immutable
class AudioBottomSheetState {
  const AudioBottomSheetState({
    required this.surahName,
    required this.surahId,
    required this.ayahId,
    required this.isLoading,
  });

  final String surahName;
  final int surahId;
  final int ayahId;
  final bool isLoading;

  AudioBottomSheetState copyWith({
    String? surahName,
    int? surahId,
    int? ayahId,
    bool? isLoading,
  }) {
    return AudioBottomSheetState(
      surahName: surahName ?? this.surahName,
      surahId: surahId ?? this.surahId,
      ayahId: ayahId ?? this.ayahId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AudioBottomSheetStateNotifier
    extends StateNotifier<AudioBottomSheetState> {
  AudioBottomSheetStateNotifier(AudioBottomSheetState state) : super(state);
  late AudioApi _audioApi;
  late AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? playerStateSubscription;

  void nextAyah() async {
    try {
      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: 1,
        surahId: state.surahId,
        ayahNumber: state.ayahId + 1,
      );
      _audioPlayer.setUrl(response.data.audioFileUrl);
      _audioPlayer.play();
      state = state.copyWith(
        ayahId: state.ayahId + 1,
      );
    } catch (e) {}
  }

  void init(
    AudioBottomSheetState initState,
    AudioApi audioApi,
    AudioPlayer audioPlayer,
  ) async {
    _audioApi = audioApi;
    state = initState;
    _audioPlayer = audioPlayer;

    try {
      if (playerStateSubscription != null) {
        playerStateSubscription?.cancel();
      }
      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: 1,
        surahId: initState.surahId,
        ayahNumber: initState.ayahId,
      );

      _audioPlayer.setUrl(response.data.audioFileUrl);
      playerStateSubscription =
          _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          nextAyah();
        }
      });
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void playAudio() {
    _audioPlayer.play();
  }

  void pauseAudio() {
    _audioPlayer.pause();
  }

  void nextSurah() async {
    final currentSurahId = state.surahId;
    final nextSurahId = currentSurahId + 1;
    try {
      state = state.copyWith(isLoading: true);
      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: 1,
        surahId: nextSurahId,
        ayahNumber: 1,
      );
      _audioPlayer.setUrl(response.data.audioFileUrl);
      state = state.copyWith(
        ayahId: 1,
        surahId: nextSurahId,
        surahName: surahNumberToSurahNameMap[nextSurahId],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final audioBottomSheetProvider =
    StateNotifierProvider<AudioBottomSheetStateNotifier, AudioBottomSheetState>(
  (ref) {
    return AudioBottomSheetStateNotifier(const AudioBottomSheetState(
      surahName: "",
      surahId: 1,
      ayahId: 1,
      isLoading: true,
    ));
  },
);
