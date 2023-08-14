import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  });

  List<ListReciterResponse>? listReciter;

  SelectReciterBottomSheetState copyWith({
    List<ListReciterResponse>? listReciter,
  }) {
    return SelectReciterBottomSheetState(
      listReciter: listReciter ?? this.listReciter,
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
  final SharedPreferenceService _sharedPreferenceService;
  @override
  Future<void> initStateNotifier() async {
    print("halo");
  }

  Future<void> fetchData(
    AudioApi audioApi,
  ) async {
    _audioApi = audioApi;

    print("xoxoxoxo");
    try {
      final request = await _audioApi.getListReciter();
      print("lololo");
      print(request.response.statusCode);
      if (request.response.statusCode == 200) {
        state = state.copyWith(
          listReciter: request.data,
        );
        print("haihaihai");

        print(request.data);
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
}

final SelectReciterBottomSheetProvider = StateNotifierProvider<
    SelectReciterStateNotifier, SelectReciterBottomSheetState>(
  (ref) {
    return SelectReciterStateNotifier(
      SelectReciterBottomSheetState(),
      ref.watch(sharedPreferenceServiceProvider),
    );
  },
);
