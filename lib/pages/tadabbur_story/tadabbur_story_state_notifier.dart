import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class TadabburStoryPageState {
  TadabburStoryPageState({
    required this.contentInfos,
    this.controller,
    this.isLoading = true,
  });

  final List<TadabburContentReadingInfo> contentInfos;
  final bool isLoading;
  final PageController? controller;

  TadabburStoryPageState copyWith({
    List<TadabburContentReadingInfo>? contentInfos,
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

  final DbLocal _db = DbLocal();

  @override
  Future<void> initStateNotifier() async {
    state = state.copyWith(isLoading: true);

    List<TadabburContentReadingInfo> res = await _initContent();

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

  Future<void> updateLatestReadStoryIndexInAyah(int value) async {
    state.contentInfos[_currentIndex].latestReadIndex = value;
    await updateLatestReadStoryIndexToDB();
  }

  Future<void> updateLatestReadStoryIndexToDB() async {
    final TadabburContentReadingInfo item = state.contentInfos[_currentIndex];

    await _db.insertOrupdateTadabburReadingContentInfoLastReadingIndex(
      tadabburID: item.tadabburID,
      lastReadingIndex: item.latestReadIndex,
    );
  }

  Future<List<TadabburContentReadingInfo>> _initContent() async {
    final TadabburContentResponse? content =
        await _getTadabburContent(_params.tadabburId);

    List<TadabburContentReadingInfo> res = [];
    _currentIndex = 0;

    if (content != null) {
      final int lastReadingIndex = await _db
          .getTadabburReadingContentInfoByTadabburID(_params.tadabburId);

      res.add(TadabburContentReadingInfo(
        content: content,
        latestReadIndex: lastReadingIndex,
        tadabburID: _params.tadabburId,
      ));

      if (content.previousTadabburId != null) {
        _currentIndex = 1;

        final TadabburContentResponse? prevContent =
            await _getTadabburContent(content.previousTadabburId!);

        if (prevContent != null) {
          final int lastReadingIndex =
              await _db.getTadabburReadingContentInfoByTadabburID(
            content.previousTadabburId!,
          );

          res.insert(
            0,
            TadabburContentReadingInfo(
              content: prevContent,
              latestReadIndex: lastReadingIndex,
              tadabburID: content.previousTadabburId!,
            ),
          );
        }
      }

      if (content.nextTadabburId != null) {
        final TadabburContentResponse? nextContent =
            await _getTadabburContent(content.nextTadabburId!);

        if (nextContent != null) {
          final int lastReadingIndex =
              await _db.getTadabburReadingContentInfoByTadabburID(
            content.nextTadabburId!,
          );
          res.add(TadabburContentReadingInfo(
            content: nextContent,
            latestReadIndex: lastReadingIndex,
            tadabburID: content.nextTadabburId!,
          ));
        }
      }
    }

    return res;
  }

  Future<void> _next() async {
    if (_currentIndex != state.contentInfos.length - 1) {
      return;
    }

    if (state.contentInfos[_currentIndex].content.nextTadabburId == null) {
      return;
    }

    List<TadabburContentReadingInfo> res = [
      ...state.contentInfos,
      TadabburContentReadingInfo(
        content: TadabburContentResponse(),
        tadabburID: 0,
      ),
    ];

    state = state.copyWith(
      contentInfos: res,
      isLoading: false,
    );

    _controller.jumpToPage(_currentIndex);

    final TadabburContentResponse? content = await _getTadabburContent(
      state.contentInfos[_currentIndex].content.nextTadabburId!,
    );

    if (content != null) {
      final int lastReadingIndex =
          await _db.getTadabburReadingContentInfoByTadabburID(
        state.contentInfos[_currentIndex].content.nextTadabburId!,
      );
      List<TadabburContentReadingInfo> res = state.contentInfos;
      res[state.contentInfos.length - 1] = TadabburContentReadingInfo(
        content: content,
        latestReadIndex: lastReadingIndex,
        tadabburID: state.contentInfos[_currentIndex].content.nextTadabburId!,
      );

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

    if (state.contentInfos[_currentIndex].content.previousTadabburId == null) {
      return;
    }

    _currentIndex += 1;

    List<TadabburContentReadingInfo> res = [
      TadabburContentReadingInfo(
        content: TadabburContentResponse(),
        tadabburID: 0,
      ),
      ...state.contentInfos,
    ];

    state = state.copyWith(
      contentInfos: res,
      isLoading: false,
    );

    _controller.jumpToPage(_currentIndex);

    final TadabburContentResponse? content = await _getTadabburContent(
      state.contentInfos[_currentIndex].content.previousTadabburId!,
    );

    if (content != null) {
      final int lastReadingIndex =
          await _db.getTadabburReadingContentInfoByTadabburID(
        res[_currentIndex].content.previousTadabburId!,
      );

      res[0] = TadabburContentReadingInfo(
        content: content,
        latestReadIndex: lastReadingIndex,
        tadabburID: res[_currentIndex].content.previousTadabburId!,
      );

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
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getListTadabburContent() method',
      );
      print(error);
    }

    return null;
  }
}
