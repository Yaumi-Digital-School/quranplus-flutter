import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_reciter_state_notifier.g.dart';

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

@Riverpod(keepAlive: true)
class SelectReciterNotifier extends _$SelectReciterNotifier {
  late AudioApi _audioApi;
  late AudioRecitationHandler _audioHandler;
  late SharedPreferenceService _sharedPreferenceService;
  StreamSubscription<PlayerState>? playerStateSubscription;

  @override
  SelectReciterBottomSheetState build() {
    _audioHandler = ref.read(audioHandler);
    _sharedPreferenceService = ref.read(sharedPreferenceServiceProvider);
    return const SelectReciterBottomSheetState(
      currentSurahName: "",
      currentSurahId: 1,
      currentAyahId: 1,
      listReciter: [],
    );
  }

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
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getListTadabbur() method',
      );
      debugPrint(error.toString());
    }
  }

  Future<void> saveDataReciter(int id, String name) async {
    await _sharedPreferenceService
        .setSelectedReciter(ReciterItemResponse(id: id, name: name));
  }

  Future<void> backToAudioBottomSheet(
    int reciterId,
    String reciterName,
    AudioRecitationNotifier audioPlayerNotifier,
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
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on nextPreviewAyah() method',
      );
    }
  }

  Future<void> updateRadioButton(int reciterId, String reciterName) async {
    state = state.copyWith(
      reciterId: reciterId,
      reciterName: reciterName,
    );
  }
}
