import 'dart:developer';

import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class TadabburStoryPageState {
  TadabburStoryPageState({
    this.contentInfo,
    this.isLoading = true,
  });

  final TadabburContentResponse? contentInfo;
  final bool isLoading;

  TadabburStoryPageState copyWith({
    TadabburContentResponse? contentInfo,
    bool isLoading = true,
  }) {
    return TadabburStoryPageState(
      contentInfo: contentInfo ?? this.contentInfo,
      isLoading: isLoading,
    );
  }
}

class TadabburStoryPageStateNotifier
    extends BaseStateNotifier<TadabburStoryPageState> {
  TadabburStoryPageStateNotifier({
    required TadabburApi tadabburApi,
    required TadabburStoryPageParams params,
  })  : _tadabburApi = tadabburApi,
        _params = params,
        super(TadabburStoryPageState());

  final TadabburApi _tadabburApi;
  final TadabburStoryPageParams _params;

  @override
  Future<void> initStateNotifier() async {
    state = state.copyWith(isLoading: true);

    try {
      HttpResponse<TadabburContentResponse> response =
          await _tadabburApi.getTadabburContent(
        tadabburId: _params.tadabburId,
      );

      if (response.response.statusCode == 200) {
        state = state.copyWith(
          contentInfo: response.data,
          isLoading: false,
        );
      }
    } catch (e) {
      // state = state.copyWith(
      //   // contentInfo: response.data,
      //   isLoading: false,
      // );
      print(e);
    }
  }
}
