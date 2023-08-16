import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:retrofit/dio.dart';

class SelectReciterBottomSheetState {
  SelectReciterBottomSheetState({
    required this.listReciter,
    required this.currentSurahId,
    required this.currentSurahName,
    required this.currentAyahId,
    this.idReciter,
    this.nameReciter,
  });

  List<ListReciterResponse> listReciter;
  final int currentSurahId;
  final String currentSurahName;
  final int currentAyahId;
  int? idReciter;
  String? nameReciter;

  SelectReciterBottomSheetState copyWith({
    List<ListReciterResponse>? listReciter,
    int? currentAyahId,
    int? currentSurahId,
    String? currentSurahName,
    int? idReciter,
    String? nameReciter,
  }) {
    return SelectReciterBottomSheetState(
      listReciter: listReciter ?? this.listReciter,
      currentAyahId: currentAyahId ?? this.currentAyahId,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      idReciter: idReciter ?? this.idReciter,
      nameReciter: nameReciter ?? this.nameReciter,
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
    int? idReciter,
    String? nameReciter,
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
          idReciter: idReciter,
          nameReciter: nameReciter,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveDataReciter(int id, String name) async {
    await _sharedPreferenceService
        .setReciterId(ListReciterResponse(id: id, name: name));
    print("save");

    //tambah trigger ke audiobottomsheetstate
  }

  Future<void> backToAudioBottomSheet(
    int id,
    String name,
    AudioRecitationStateNotifier _audioPlayerNotifier,
  ) async {
    final AudioRecitationState newState = AudioRecitationState(
      surahName: state.currentSurahName,
      surahId: state.currentSurahId,
      ayahId: state.currentAyahId,
      isLoading: true,
      id: id,
      nameReciter: name,
    );

    await _audioPlayerNotifier.init(newState);

    _audioPlayerNotifier.playAudio();
    print("halo in back too");
    // _setShowMinimizedRecitationInfo(true);
  }

  Future<void> playPreviewAudio(int id, int ayahId) async {
    if (playerStateSubscription != null) {
      playerStateSubscription?.cancel();
    }

    final response = await _audioApi.getAudioForSpecificReciterAndAyah(
      reciterId: id,
      surahId: 1,
      ayahNumber: 1,
    );
    _audioHandler.pause();
    if (ayahId < 2) {
      _audioHandler.setMediaItem(
        MediaItem(
          id: '${1}-${1}-$id',
          title: '${1} - Ayat: ${1}',
          // replace with dynamic reciter name (done)
          artist: state.listReciter[id].name,
          extras: <String, dynamic>{
            'url': response.data.audioFileUrl,
          },
        ),
      );
      _audioHandler.play();

      playerStateSubscription = _audioHandler.getStreamOnFinishedEvent(
        () => nextAyah(ayahId, id),
      );
    }

    playerStateSubscription = _audioHandler.getStreamOnFinishedEvent(
      () => _audioHandler.stop(),
    );

    //stopAndResetAudioPlayer();
  }

  Future<void> nextAyah(int ayahId, int reciterId) async {
    try {
      final int nextAyahNumber = ayahId + 1;

      final response = await _audioApi.getAudioForSpecificReciterAndAyah(
        reciterId: reciterId,
        surahId: 1,
        ayahNumber: nextAyahNumber,
      );

      _audioHandler.setMediaItem(
        MediaItem(
          id: '${1}-$ayahId-$reciterId',
          title: '${1} - Ayat: $ayahId',
          // replace with dynamic reciter name (done)
          artist: state.listReciter[reciterId].name,
          extras: <String, dynamic>{
            'url': response.data.audioFileUrl,
          },
        ),
      );
      _audioHandler.play();
      playerStateSubscription = _audioHandler.getStreamOnFinishedEvent(
        () => playPreviewAudio(reciterId, nextAyahNumber),
      );
    } catch (e) {
      //TODO Add error tracker
    }
  }

  void stopAndResetAudioPlayer() {
    _audioHandler.stop();
  }
}

final SelectReciterBottomSheetProvider = StateNotifierProvider<
    SelectReciterStateNotifier, SelectReciterBottomSheetState>(
  (ref) {
    return SelectReciterStateNotifier(
      ref.read(audioHandler),
      SelectReciterBottomSheetState(
        currentSurahName: "",
        currentSurahId: 1,
        currentAyahId: 1,
        listReciter: [],
      ),
      ref.watch(sharedPreferenceServiceProvider),
    );
  },
);
