import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/apis/audio_api.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/Select_Recitator_buttom_sheet.dart';
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
  SelectReciterStateNotifier(SelectReciterBottomSheetState state)
      : super(state);
  late AudioApi _audioApi;

  Future<void> initStateNotifier() async {
    print("halo");
    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      final HttpResponse<List<ListReciterResponse>> request =
          await _audioApi.getListReciter();
      print(request);
      if (request.response.statusCode == 200) {
        state = state.copyWith(
          listReciter: request.data,
        );
        print("haihaihai");

        print(request.data);

        return;
      }
    } catch (e) {}
  }
}

final SelectReciterBottomSheetProvider = StateNotifierProvider<
    SelectReciterStateNotifier, SelectReciterBottomSheetState>(
  (ref) {
    return SelectReciterStateNotifier(SelectReciterBottomSheetState());
  },
);
