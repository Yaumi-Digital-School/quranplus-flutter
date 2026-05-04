import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_habit_state.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/last_recording_data.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

part 'surat_page_habit_notifier.g.dart';

@riverpod
class SuratPageHabitNotifier extends _$SuratPageHabitNotifier {
  final DbLocal _db = DbLocal();
  late AutoScrollController _scrollController;
  final List<int> recordedPagesList = <int>[];
  int _startPageOnRecord = 0;
  double _scrollDownOffset = 0;
  double _scrollUpOffset = 0;
  HabitDailySummary? _currentSummary;

  SharedPreferenceService get _sharedPref =>
      ref.read(sharedPreferenceServiceProvider);
  HabitDailySummaryService get _habitDailySummaryService =>
      ref.read(habitDailySummaryService);
  AuthenticationService get _authService => ref.read(authenticationService);
  AudioRecitationNotifier get _audioNotifier =>
      ref.read(audioRecitationProvider.notifier);

  bool get isLoggedIn => _authService.isLoggedIn;
  int get habitDailyTarget => _currentSummary?.target ?? 0;
  SharedPreferenceService get sharedPreferenceService => _sharedPref;

  @override
  SuratPageHabitState build() => const SuratPageHabitState();

  void init(AutoScrollController scrollController) {
    _scrollController = scrollController;
    _scrollController.addListener(_listenOnScrollChanges);

    final audioState = ref.read(audioRecitationProvider);
    state = state.copyWith(
      showMinimizedAudioPlayer: !audioState.isStopped,
    );
  }

  void _listenOnScrollChanges() {
    final double currentOffset = _scrollController.offset;
    final bool onScrollUpChecking =
        (_scrollUpOffset - currentOffset >= 150) &&
            _scrollController.position.userScrollDirection ==
                ScrollDirection.forward;
    final bool onScrollDownChecking =
        (currentOffset - _scrollDownOffset >= 150) &&
            _scrollController.position.userScrollDirection ==
                ScrollDirection.reverse;

    if (onScrollUpChecking) {
      if (!state.isOnReadCTAVisible) {
        state = state.copyWith(isOnReadCTAVisible: true);
      }
      _scrollDownOffset = currentOffset;
    }

    if (onScrollDownChecking) {
      if (state.isOnReadCTAVisible) {
        state = state.copyWith(isOnReadCTAVisible: false);
      }
      _scrollUpOffset = currentOffset;
    }
  }

  void changePageOnRecording(int page) {
    final int addedPage = page - 1;
    if (addedPage < _startPageOnRecord) return;

    if (recordedPagesList.isEmpty) {
      if (_startPageOnRecord > 0) {
        recordedPagesList.add(addedPage);
        state = state.copyWith(
          recordedPagesAsRead: state.recordedPagesAsRead + 1,
        );
      }
      return;
    }

    if (recordedPagesList.contains(addedPage)) return;

    recordedPagesList.add(addedPage);
    state = state.copyWith(
      recordedPagesAsRead: state.recordedPagesAsRead + 1,
    );
  }

  Future<void> startRecording() async {
    _currentSummary = await _db.getCurrentDayHabitDailySummary();
    final navState = ref.read(suratPageNavigationProvider);
    _startPageOnRecord = navState.currentPage;
    state = state.copyWith(
      isRecording: true,
      recordedPagesAsRead: _currentSummary?.totalPages ?? 0,
    );
  }

  Future<bool> stopRecording(int recordedPages) async {
    state = state.copyWith(isRecording: false);

    if (recordedPages > 0) {
      final navState = ref.read(suratPageNavigationProvider);
      await _db.submitHabitProgressWithDailySummaryByTracking(
        pages: recordedPages,
        startPage: _startPageOnRecord,
        summary: _currentSummary!,
      );

      await _sharedPref.setLastRecordingData(
        LastRecordingData(
          surahName: navState.visibleSuratName,
          page: navState.currentPage,
        ),
      );

      recordedPagesList.clear();
      state = state.copyWith(isHabitDailySummaryChanged: true);
    }

    _startPageOnRecord = 0;
    final int totalReadPages = recordedPages + (_currentSummary!.totalPages);

    try {
      await _habitDailySummaryService.syncHabit();
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on stopRecording() syncHabit',
      );
    }

    return totalReadPages >= (_currentSummary!.target);
  }

  void setShowMinimizedAudioPlayer(bool value) {
    state = state.copyWith(showMinimizedAudioPlayer: value);
  }

  void stopRecitation() {
    _audioNotifier.stopAndResetAudioPlayer();
    setShowMinimizedAudioPlayer(false);
  }

  Future<void> playOnAyah(Verse verse) async {
    final ReciterItemResponse reciterItemResponse =
        await _sharedPref.getSelectedReciter();

    final AudioRecitationState newState = AudioRecitationState(
      surahName: verse.surahName,
      surahId: verse.surahNumber,
      ayahId: verse.verseNumber,
      isLoading: true,
      reciterId: reciterItemResponse.id,
      reciterName: reciterItemResponse.name,
    );

    await _audioNotifier.init(newState);
    _audioNotifier.playAudio();
    setShowMinimizedAudioPlayer(true);
  }

  Future<void> playAyahAudio() async {
    _audioNotifier.playAudio();
    setShowMinimizedAudioPlayer(true);
  }

  void forceLoginToEnableHabit(
    BuildContext context,
    String redirectTo,
    Map<String, dynamic> arguments,
  ) {
    _authService.forceLoginAndSaveRedirectTo(
      context: context,
      redirectTo: redirectTo,
      arguments: arguments,
    );
  }
}
