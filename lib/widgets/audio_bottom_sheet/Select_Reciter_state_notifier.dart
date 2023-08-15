import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Recitator_buttom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_state_notifier.dart';
import 'package:retrofit/dio.dart';

class SelectReciterBottomSheetState {
  SelectReciterBottomSheetState({
    this.listReciter,
    required this.currentSurahId,
    required this.currentSurahName,
    required this.currentAyahId,
    this.idReciter,
    this.nameReciter,
  });

  List<ListReciterResponse>? listReciter;
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
    SelectReciterBottomSheetState state,
    SharedPreferenceService sharedPreferenceService,
  )   : _sharedPreferenceService = sharedPreferenceService,
        super(state);
  late AudioApi _audioApi;
  late AudioPlayer _audioPlayer;
  final SharedPreferenceService _sharedPreferenceService;
  @override
  Future<void> fetchData(
    String surahName,
    int surahId,
    int ayahId,
    AudioApi audioApi,
    int? idReciter,
    String? nameReciter,
    AudioPlayer audioPlayer,
  ) async {
    _audioApi = audioApi;
    _audioPlayer = audioPlayer;

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
    AudioBottomSheetStateNotifier _audioPlayerNotifier,
  ) async {
    await _audioPlayerNotifier.init(
      AudioBottomSheetState(
        surahName: state.currentSurahName,
        surahId: state.currentSurahId,
        ayahId: state.currentAyahId,
        isLoading: true,
        id: id,
        nameReciter: name,
      ),
      _audioApi,
      _audioPlayer,
    );
    _audioPlayerNotifier.playAudio();
    print("halo in back too");
    // _setShowMinimizedRecitationInfo(true);
  }
}

final SelectReciterBottomSheetProvider = StateNotifierProvider<
    SelectReciterStateNotifier, SelectReciterBottomSheetState>(
  (ref) {
    return SelectReciterStateNotifier(
      SelectReciterBottomSheetState(
        currentSurahName: "",
        currentSurahId: 1,
        currentAyahId: 1,
      ),
      ref.watch(sharedPreferenceServiceProvider),
    );
  },
);
