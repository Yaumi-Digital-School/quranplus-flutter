import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class ReadTadabburState {
  bool isLoading;
  bool isError;
  List<TadabburItemResponse> listTadabbur;

  ReadTadabburState({
    this.isError = false,
    this.isLoading = true,
    this.listTadabbur = const [],
  });

  ReadTadabburState copyWith({
    bool? isLoading,
    bool? isError,
    List<TadabburItemResponse>? listTadabbur,
  }) {
    return ReadTadabburState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      listTadabbur: listTadabbur ?? this.listTadabbur,
    );
  }
}

class ReadTadabburStateNotifier extends BaseStateNotifier<ReadTadabburState> {
  ReadTadabburStateNotifier({
    required TadabburApi tadabburApi,
    required int surahId,
  })  : _tadabburApi = tadabburApi,
        _surahId = surahId,
        super(ReadTadabburState());
  final TadabburApi _tadabburApi;
  final int _surahId;

  @override
  initStateNotifier() async {
    await _getListTadabbur(_surahId);
  }

  Future<void> _getListTadabbur(int surahId) async {
    try {
      state = state.copyWith(isLoading: true, isError: false);
      final result =
          await _tadabburApi.getListTadabburOfSurah(surahId: surahId);
      state = state.copyWith(isLoading: false, listTadabbur: result.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
