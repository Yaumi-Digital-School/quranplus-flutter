import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class TadabburSurahListViewState {
  TadabburSurahListViewState({
    this.tadabburSurahList,
    this.isLoading = true,
  });

  final List<GetTadabburSurahListItemResponse>? tadabburSurahList;
  final bool isLoading;

  TadabburSurahListViewState copyWith({
    List<GetTadabburSurahListItemResponse>? tadabburSurahList,
    bool? isLoading,
  }) {
    return TadabburSurahListViewState(
      tadabburSurahList: tadabburSurahList ?? this.tadabburSurahList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TadabburSurahListViewStateNotifier
    extends BaseStateNotifier<TadabburSurahListViewState> {
  TadabburSurahListViewStateNotifier({
    required TadabburApi tadabburApi,
  })  : _tadabburApi = tadabburApi,
        super(
          TadabburSurahListViewState(),
        );

  final TadabburApi _tadabburApi;

  @override
  Future<void> initStateNotifier() async {
    await _getAvailableTadabburSurahList();
  }

  Future<void> _getAvailableTadabburSurahList() async {
    try {
      HttpResponse<List<GetTadabburSurahListItemResponse>> request =
          await _tadabburApi.getAvailableTadabburSurahList();

      if ((request.response.statusCode ?? 400) == 200) {
        state = state.copyWith(
          tadabburSurahList: request.data,
          isLoading: false,
        );

        return;
      }

      state = state.copyWith(
        tadabburSurahList: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        tadabburSurahList: [],
        isLoading: false,
      );
    }
  }
}
