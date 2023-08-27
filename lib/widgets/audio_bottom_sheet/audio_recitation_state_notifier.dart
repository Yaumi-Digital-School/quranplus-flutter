import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Reciter_state_notifier.dart';

class AudioRecitationState {
  AudioRecitationState({
    this.surahName = '',
    this.surahId = 1,
    this.ayahId = 1,
    this.isLoading = true,
    this.reciterId,
    this.reciterName,
  });

  String surahName;
  int surahId;
  int ayahId;
  bool isLoading;
  final int? reciterId;
  final String? reciterName;

  AudioRecitationState copyWith({
    String? surahName,
    int? surahId,
    int? ayahId,
    bool? isLoading,
    int? reciterId,
    String? reciterName,
  }) {
    return AudioRecitationState(
      surahName: surahName ?? this.surahName,
      surahId: surahId ?? this.surahId,
      ayahId: ayahId ?? this.ayahId,
      isLoading: isLoading ?? this.isLoading,
      reciterId: reciterId ?? this.reciterId,
      reciterName: reciterName ?? this.reciterName,
    );
  }

  bool get isStopped => surahName.isEmpty;
}

class AudioRecitationStateNotifier extends StateNotifier<AudioRecitationState> {
  AudioRecitationStateNotifier({
    required AudioApi audioApi,
    required AudioRecitationHandler audioHandler,
  })  : _audioApi = audioApi,
        _audioHandler = audioHandler,
        super(
          AudioRecitationState(),
        );

  final AudioApi _audioApi;
  final AudioRecitationHandler _audioHandler;

  final List<MediaItem> localPlaylist = [];

  StreamSubscription<PlayerState>? playerStateSubscription;

  Future<void> getNextAyahMedia() async {
    final bool shouldGoToNextSurah =
        state.ayahId + 1 > (surahNumberToTotalAyahMap[state.surahId] ?? 0);

    final int nextSurahId =
        shouldGoToNextSurah ? state.surahId + 1 : state.surahId;
    final int nextAyahNumber = shouldGoToNextSurah ? 1 : state.ayahId + 1;

    final response = await _audioApi.getAudioForSpecificReciterAndAyah(
      reciterId: state.reciterId!,
      surahId: nextSurahId,
      ayahNumber: nextAyahNumber,
    );

    final MediaItem item = MediaItem(
      id: '$nextSurahId-$nextAyahNumber-${state.reciterId}',
      title:
          '${surahNumberToSurahNameMap[nextSurahId]} - Ayat: $nextAyahNumber',
      artist: state.reciterName,
      extras: <String, dynamic>{
        'url': response.data.audioFileUrl,
      },
    );

    localPlaylist.add(item);
  }

  Future<void> nextAyah() async {
    try {
      final bool shouldGoToNextSurah =
          state.ayahId + 1 > (surahNumberToTotalAyahMap[state.surahId] ?? 0);

      final int nextSurahId =
          shouldGoToNextSurah ? state.surahId + 1 : state.surahId;
      final int nextAyahNumber = shouldGoToNextSurah ? 1 : state.ayahId + 1;

      MediaItem nextMedia = localPlaylist.last;

      _audioHandler.setMediaItem(nextMedia);
      _audioHandler.play();

      state = state.copyWith(
        surahId: nextSurahId,
        ayahId: nextAyahNumber,
        surahName: surahNumberToSurahNameMap[nextSurahId] ?? '',
      );

      getNextAyahMedia();
    } catch (e) {
      //TODO Add error tracker
    }
  }

  Future<void> init(
    AudioRecitationState initState, {
    Function()? onSuccess,
    Function()? onLoadError,
    Function()? onPlayBackError,
  }) async {
    localPlaylist.clear();
    state = initState;

    _audioHandler.setOnSkipNext(nextSurah);
    _audioHandler.setOnSkipPrevious(previousSurah);

    try {
      if (playerStateSubscription != null) {
        playerStateSubscription?.cancel();
      }

      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: state.reciterId!,
        surahId: initState.surahId,
        ayahNumber: initState.ayahId,
      );

      _initAudioHandlerState(
        initState,
        response.data.audioFileUrl,
      );

      await getNextAyahMedia();

      state = state.copyWith(isLoading: false);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (onLoadError != null) onLoadError();
    }

    if (onPlayBackError != null) {
      _audioHandler.setOnPlaybackError(onPlayBackError);
    }
  }

  Future<void> _initAudioHandlerState(
    AudioRecitationState newState,
    String url,
  ) async {
    _audioHandler.pause();
    MediaItem item = MediaItem(
      id: '${newState.surahId}-${newState.ayahId}-${state.reciterId}',
      title: '${newState.surahName} - Ayat: ${newState.ayahId}',
      artUri: Uri.directory('images/logogram.png', windows: false),
      artist: state.reciterName,
      extras: <String, dynamic>{
        'url': url,
      },
    );

    _audioHandler.setMediaItem(item);
    localPlaylist.add(item);

    playerStateSubscription = _audioHandler.getStreamOnFinishedEvent(
      () => nextAyah(),
    );
  }

  void playAudio() {
    _audioHandler.play();
  }

  void pauseAudio() {
    _audioHandler.pause();
  }

  void stopAndResetAudioPlayer() {
    _audioHandler.stop();
    state = AudioRecitationState();
  }

  Future<void> _startNewSurah(int surahId) async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: 1,
        surahId: surahId,
        ayahNumber: 1,
      );

      final String surahName = surahNumberToSurahNameMap[surahId] ?? '';

      MediaItem item = MediaItem(
        id: '$surahId-1-${state.reciterId}',
        title: '$surahName - Ayat: 1',
        // replace with dynamic reciter name
        artist: state.reciterName,
        extras: <String, dynamic>{
          'url': response.data.audioFileUrl,
        },
      );

      _audioHandler.setMediaItem(item);
      localPlaylist.add(item);

      state = state.copyWith(
        ayahId: 1,
        surahId: surahId,
        surahName: surahNumberToSurahNameMap[surahId],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> nextSurah() async {
    final int currentSurahId = state.surahId;
    final int nextSurahId = currentSurahId + 1;
    await _startNewSurah(nextSurahId);
  }

  Future<void> previousSurah() async {
    final int currentSurahId = state.surahId;
    final int previousSurahId = currentSurahId - 1;
    await _startNewSurah(previousSurahId);
  }

  Future<void> changeReciter(
    SelectReciterStateNotifier _selectReciterNotifier,
  ) async {
    await _selectReciterNotifier.fetchData(
      state.surahName,
      state.surahId,
      state.ayahId,
      _audioApi,
      state.reciterId,
      state.reciterName,
    );
  }
}

final audioRecitationProvider =
    StateNotifierProvider<AudioRecitationStateNotifier, AudioRecitationState>(
  (ref) {
    final AudioApi _audioApi = ref.read(audioApiProvider);
    final AudioRecitationHandler _audioRecitationHandler =
        ref.read(audioHandler);

    return AudioRecitationStateNotifier(
      audioApi: _audioApi,
      audioHandler: _audioRecitationHandler,
    );
  },
);
