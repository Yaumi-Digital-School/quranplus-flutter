import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';

class SelectReciterBottomSheetState {
  const SelectReciterBottomSheetState({
    required this.listReciter,
    required this.currentSurahId,
    required this.currentSurahName,
    required this.currentAyahId,
    this.reciterId,
    this.reciterName,
  });

  final List<ReciterItemResponse> listReciter;
  final int currentSurahId;
  final String currentSurahName;
  final int currentAyahId;
  final int? reciterId;
  final String? reciterName;

  SelectReciterBottomSheetState copyWith({
    List<ReciterItemResponse>? listReciter,
    int? currentAyahId,
    int? currentSurahId,
    String? currentSurahName,
    int? reciterId,
    String? reciterName,
  }) {
    return SelectReciterBottomSheetState(
      listReciter: listReciter ?? this.listReciter,
      currentAyahId: currentAyahId ?? this.currentAyahId,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      reciterId: reciterId ?? this.reciterId,
      reciterName: reciterName ?? this.reciterName,
    );
  }
}

class SelectReciterStateNotifier
    extends StateNotifier<SelectReciterBottomSheetState> {
  SelectReciterStateNotifier(
    AudioRecitationHandler audioHandler,
    SelectReciterBottomSheetState state,
    SharedPreferenceService sharedPreferenceService,
  )   : _sharedPreferenceService = sharedPreferenceService,
        _audioHandler = audioHandler,
        super(state);
  late AudioApi _audioApi;
  final AudioRecitationHandler _audioHandler;
  final SharedPreferenceService _sharedPreferenceService;
  StreamSubscription<PlayerState>? playerStateSubscription;

  Future<void> fetchData(
    String surahName,
    int surahId,
    int ayahId,
    AudioApi audioApi,
    int? reciterId,
    String? reciterName,
  ) async {
    _audioApi = audioApi;

    try {
      final request = await _audioApi.getListReciter();

      if (request.response.statusCode == 200) {
        state = state.copyWith(
          listReciter: request.data,
          currentAyahId: ayahId,
          currentSurahId: surahId,
          currentSurahName: surahName,
          reciterId: reciterId,
          reciterName: reciterName,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveDataReciter(int id, String name) async {
    await _sharedPreferenceService
        .setSelectedReciter(ReciterItemResponse(id: id, name: name));

    //tambah trigger ke audiobottomsheetstate
  }

  Future<void> backToAudioBottomSheet(
    int reciterId,
    String reciterName,
    AudioRecitationStateNotifier audioPlayerNotifier,
  ) async {
    final AudioRecitationState newState = AudioRecitationState(
      surahName: state.currentSurahName,
      surahId: state.currentSurahId,
      ayahId: state.currentAyahId,
      isLoading: true,
      reciterId: reciterId,
      reciterName: reciterName,
    );

    await audioPlayerNotifier.init(newState);

    audioPlayerNotifier.playAudio();
  }

  Future<void> playPreviewAudio(int reciterId) async {
    int ayahId = 1;
    if (playerStateSubscription != null) {
      playerStateSubscription?.cancel();
    }

    final response = await _audioApi.getAudioForSpecificReciterAndAyah(
      reciterId: reciterId,
      surahId: 1,
      ayahNumber: 1,
    );
    _audioHandler.pause();
    if (ayahId < 2) {
      _audioHandler.setUrl(response.data.audioFileUrl);
      _audioHandler.play();

      playerStateSubscription = _audioHandler.getStreamOnFinishedEvent(
        () => nextPreviewAyah(ayahId, reciterId),
      );
    }
  }

  Future<void> nextPreviewAyah(int ayahId, int reciterId) async {
    try {
      if (playerStateSubscription != null) {
        playerStateSubscription?.cancel();
      }
      final int nextAyahNumber = ayahId + 1;

      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: reciterId,
        surahId: 1,
        ayahNumber: nextAyahNumber,
      );

      _audioHandler.setUrl(response.data.audioFileUrl);
      _audioHandler.play();
      playerStateSubscription = _audioHandler.getStreamOnFinishedEvent(
        () => _audioHandler.stop(),
      );
    } catch (e) {
      //TODO Add error tracker
    }
  }

  Future<void> updateRadioButton(int reciterId, String reciterName) async {
    state = state.copyWith(
      reciterId: reciterId,
      reciterName: reciterName,
    );
  }
}

final selectReciterBottomSheetProvider = StateNotifierProvider<
    SelectReciterStateNotifier, SelectReciterBottomSheetState>(
  (ref) {
    return SelectReciterStateNotifier(
      ref.read(audioHandler),
      const SelectReciterBottomSheetState(
        currentSurahName: "",
        currentSurahId: 1,
        currentAyahId: 1,
        listReciter: [],
      ),
      ref.watch(sharedPreferenceServiceProvider),
    );
  },
);
// final listReciterProvider = StateProvider<List<ReciterItemResponse>>((ref) {
//   final stateReiter = ref.watch(selectReciterBottomSheetProvider);

//   return stateReiter.listReciter;
// });
