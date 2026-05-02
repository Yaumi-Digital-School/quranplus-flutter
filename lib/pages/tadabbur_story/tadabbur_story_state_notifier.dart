import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tadabbur_story_state_notifier.g.dart';

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

@riverpod
class TadabburStoryPageNotifier extends _$TadabburStoryPageNotifier {
  late int _currentIndex;
  late PageController _controller;
  final DbLocal _db = DbLocal();

  @override
  TadabburStoryPageState build() => TadabburStoryPageState(contentInfos: []);

  Future<void> init(TadabburStoryPageParams params) async {
    state = state.copyWith(isLoading: true);

    final res = await _initContent(params);

    _controller = PageController(initialPage: _currentIndex);
    _controller.addListener(() {
      final int index = _controller.page! > _currentIndex
          ? _controller.page!.floor()
          : _controller.page!.ceil();

      if (index == _currentIndex) return;

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
    await _updateLatestReadStoryIndexToDB();
  }

  Future<void> updateLatestReadStoryIndexToDB() async {
    await _updateLatestReadStoryIndexToDB();
  }

  Future<void> _updateLatestReadStoryIndexToDB() async {
    final item = state.contentInfos[_currentIndex];
    await _db.insertOrupdateTadabburReadingContentInfoLastReadingIndex(
      tadabburID: item.tadabburID,
      lastReadingIndex: item.latestReadIndex,
    );
  }

  Future<List<TadabburContentReadingInfo>> _initContent(
      TadabburStoryPageParams params) async {
    final content = await _getTadabburContent(params.tadabburId);
    List<TadabburContentReadingInfo> res = [];
    _currentIndex = 0;

    if (content != null) {
      final lastReadingIndex =
          await _db.getTadabburReadingContentInfoByTadabburID(params.tadabburId);
      res.add(TadabburContentReadingInfo(
        content: content,
        latestReadIndex: lastReadingIndex,
        tadabburID: params.tadabburId,
      ));

      if (content.previousTadabburId != null) {
        _currentIndex = 1;
        final prevContent =
            await _getTadabburContent(content.previousTadabburId!);
        if (prevContent != null) {
          final lastIdx = await _db
              .getTadabburReadingContentInfoByTadabburID(content.previousTadabburId!);
          res.insert(0, TadabburContentReadingInfo(
            content: prevContent,
            latestReadIndex: lastIdx,
            tadabburID: content.previousTadabburId!,
          ));
        }
      }

      if (content.nextTadabburId != null) {
        final nextContent =
            await _getTadabburContent(content.nextTadabburId!);
        if (nextContent != null) {
          final lastIdx = await _db
              .getTadabburReadingContentInfoByTadabburID(content.nextTadabburId!);
          res.add(TadabburContentReadingInfo(
            content: nextContent,
            latestReadIndex: lastIdx,
            tadabburID: content.nextTadabburId!,
          ));
        }
      }
    }

    return res;
  }

  Future<void> _next() async {
    if (_currentIndex != state.contentInfos.length - 1) return;
    if (state.contentInfos[_currentIndex].content.nextTadabburId == null) return;

    List<TadabburContentReadingInfo> res = [
      ...state.contentInfos,
      TadabburContentReadingInfo(content: TadabburContentResponse(), tadabburID: 0),
    ];

    state = state.copyWith(contentInfos: res, isLoading: false);
    _controller.jumpToPage(_currentIndex);

    final nextId = state.contentInfos[_currentIndex].content.nextTadabburId!;
    final content = await _getTadabburContent(nextId);

    if (content != null) {
      final lastIdx = await _db.getTadabburReadingContentInfoByTadabburID(nextId);
      List<TadabburContentReadingInfo> updated = state.contentInfos;
      updated[state.contentInfos.length - 1] = TadabburContentReadingInfo(
        content: content,
        latestReadIndex: lastIdx,
        tadabburID: nextId,
      );
      state = state.copyWith(contentInfos: updated, isLoading: false);
    }
  }

  Future<void> _prev() async {
    if (_currentIndex != 0) return;
    if (state.contentInfos[_currentIndex].content.previousTadabburId == null) return;

    _currentIndex += 1;

    List<TadabburContentReadingInfo> res = [
      TadabburContentReadingInfo(content: TadabburContentResponse(), tadabburID: 0),
      ...state.contentInfos,
    ];

    state = state.copyWith(contentInfos: res, isLoading: false);
    _controller.jumpToPage(_currentIndex);

    final prevId = res[_currentIndex].content.previousTadabburId!;
    final content = await _getTadabburContent(prevId);

    if (content != null) {
      final lastIdx = await _db.getTadabburReadingContentInfoByTadabburID(prevId);
      res[0] = TadabburContentReadingInfo(
        content: content,
        latestReadIndex: lastIdx,
        tadabburID: prevId,
      );
      state = state.copyWith(contentInfos: res, isLoading: false);
    }
  }

  Future<TadabburContentResponse?> _getTadabburContent(int tadabburId) async {
    final api = ref.read(tadabburApiProvider);
    try {
      HttpResponse<TadabburContentResponse> response =
          await api.getTadabburContent(tadabburId: tadabburId);
      if (response.response.statusCode == 200) return response.data;
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getTadabburContent() method',
      );
      debugPrint(error.toString());
    }
    return null;
  }
}
