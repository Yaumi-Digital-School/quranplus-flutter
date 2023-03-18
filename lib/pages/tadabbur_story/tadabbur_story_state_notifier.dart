import 'package:flutter/widgets.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class TadabburStoryPageState {
  TadabburStoryPageState({
    required this.contentInfos,
    this.controller,
    this.isLoading = true,
  });

  final List<TadabburContentResponse> contentInfos;
  final bool isLoading;
  final PageController? controller;

  TadabburStoryPageState copyWith({
    List<TadabburContentResponse>? contentInfos,
    PageController? controller,
    bool isLoading = true,
  }) {
    return TadabburStoryPageState(
      contentInfos: contentInfos ?? this.contentInfos,
      isLoading: isLoading,
      controller: controller ?? this.controller,
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
        super(
          TadabburStoryPageState(
            contentInfos: [],
          ),
        );

  final TadabburApi _tadabburApi;
  final TadabburStoryPageParams _params;

  late int _currentIndex;
  late PageController _controller;

  @override
  Future<void> initStateNotifier() async {
    state = state.copyWith(isLoading: true);

    List<TadabburContentResponse> res = await _initContent();

    _controller = PageController(initialPage: _currentIndex);

    _controller.addListener(() {
      final int index = _controller.page! > _currentIndex
          ? _controller.page!.floor()
          : _controller.page!.ceil();

      if (index == _currentIndex) {
        return;
      }

      if (index == _currentIndex - 1) {
        _currentIndex = index;
        _prev();
      } else if (index == _currentIndex + 1) {
        _currentIndex = index;
        _next();
      }
    });

    state = state.copyWith(
      contentInfos: res,
      isLoading: false,
      controller: _controller,
    );
  }

  Future<List<TadabburContentResponse>> _initContent() async {
    final TadabburContentResponse? content =
        await _getTadabburContent(_params.tadabburId);

    List<TadabburContentResponse> res = [];
    _currentIndex = 0;

    if (content != null) {
      res.add(content);

      if (content.previousTadabburId != null) {
        _currentIndex = 1;

        final TadabburContentResponse? prevContent =
            await _getTadabburContent(content.previousTadabburId!);

        if (prevContent != null) {
          res.insert(0, prevContent);
        }
      }

      if (content.nextTadabburId != null) {
        final TadabburContentResponse? nextContent =
            await _getTadabburContent(content.nextTadabburId!);

        if (nextContent != null) {
          res.add(nextContent);
        }
      }
    }

    return res;
  }

  Future<void> _next() async {
    if (_currentIndex != state.contentInfos.length - 1) {
      return;
    }

    if (state.contentInfos[_currentIndex].nextTadabburId == null) {
      return;
    }

    List<TadabburContentResponse> res = [
      ...state.contentInfos,
      TadabburContentResponse(),
    ];

    state = state.copyWith(
      contentInfos: res,
      isLoading: false,
    );

    _controller.jumpToPage(_currentIndex);

    final TadabburContentResponse? content = await _getTadabburContent(
      state.contentInfos[_currentIndex].nextTadabburId!,
    );

    if (content != null) {
      List<TadabburContentResponse> res = state.contentInfos;
      res[state.contentInfos.length - 1] = content;

      state = state.copyWith(
        contentInfos: res,
        isLoading: false,
      );
    }
  }

  Future<void> _prev() async {
    if (_currentIndex != 0) {
      return;
    }

    if (state.contentInfos[_currentIndex].previousTadabburId == null) {
      return;
    }

    _currentIndex += 1;

    List<TadabburContentResponse> res = [
      TadabburContentResponse(),
      ...state.contentInfos,
    ];

    state = state.copyWith(
      contentInfos: res,
      isLoading: false,
    );

    _controller.jumpToPage(_currentIndex);

    final TadabburContentResponse? content = await _getTadabburContent(
      state.contentInfos[_currentIndex].previousTadabburId!,
    );

    if (content != null) {
      List<TadabburContentResponse> res = state.contentInfos;
      res[0] = content;

      state = state.copyWith(
        contentInfos: res,
        isLoading: false,
      );
    }
  }

  Future<TadabburContentResponse?> _getTadabburContent(int tadabburId) async {
    try {
      HttpResponse<TadabburContentResponse> response =
          await _tadabburApi.getTadabburContent(
        tadabburId: tadabburId,
      );

      if (response.response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print(e);
    }

    return null;
  }
}
