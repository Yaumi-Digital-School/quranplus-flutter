import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/models/last_recording_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/verse_topage.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_page_state_notifier.g.dart';

class HomePageState {
  HomePageState({
    this.name = '',
    this.token = '',
    this.juzElements,
    this.feedbackUrl,
    this.ayahPage,
    this.dailySummary,
    required this.isNeedSync,
    this.listTaddaburAvailables,
    this.lastBookmark,
    this.lastRecordingData,
    this.audioSuratLoaded,
  });

  String token;
  String name;
  List<JuzElement>? juzElements;
  String? feedbackUrl;
  Map<String, List<String>>? ayahPage;
  HabitDailySummary? dailySummary;
  bool isNeedSync;
  Map<int, int>? listTaddaburAvailables;
  Bookmarks? lastBookmark;
  LastRecordingData? lastRecordingData;
  SuratByJuz? audioSuratLoaded;

  HomePageState copyWith({
    String? token,
    String? name,
    List<JuzElement>? juzElements,
    String? feedbackUrl,
    Map<String, List<String>>? ayahPage,
    HabitDailySummary? dailySummary,
    bool? isNeedSync,
    Map<int, int>? listTaddaburAvailables,
    Bookmarks? lastBookmark,
    LastRecordingData? lastRecordingData,
    SuratByJuz? audioSuratLoaded,
  }) {
    return HomePageState(
      token: token ?? this.token,
      name: name ?? this.name,
      juzElements: juzElements ?? this.juzElements,
      feedbackUrl: feedbackUrl ?? this.feedbackUrl,
      ayahPage: ayahPage ?? this.ayahPage,
      dailySummary: dailySummary ?? this.dailySummary,
      isNeedSync: isNeedSync ?? this.isNeedSync,
      listTaddaburAvailables:
          listTaddaburAvailables ?? this.listTaddaburAvailables,
      lastBookmark: lastBookmark ?? this.lastBookmark,
      lastRecordingData: lastRecordingData ?? this.lastRecordingData,
      audioSuratLoaded: audioSuratLoaded,
    );
  }
}

@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  final DbLocal _db = DbLocal();
  bool loginBottomSheetAlreadyBuilt = false;

  @override
  HomePageState build() {
    Future.microtask(_init);
    return HomePageState(isNeedSync: false);
  }

  Future<void> _init() async {
    try {
      _getUsername();
      _isNeedSync();
      await Future.wait([
        _getVerseToAyahPage(),
        _getJuzElements(),
        _getLastRecordingData(),
        _getLastBookmark(),
        _getDailySummary(),
        _getTaddaburSurahAvaliable(),
      ]);
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _init() method',
      );
    }
  }

  Future<void> initAyahAudio({
    required SuratByJuz surat,
    required Function() onSuccess,
    required Function() onLoadError,
    required Function() onPlayBackError,
  }) async {
    state = state.copyWith(audioSuratLoaded: surat);
    final sp = ref.read(sharedPreferenceServiceProvider);
    final reciter = await sp.getSelectedReciter();

    final newAudioState = AudioRecitationState(
      surahName: surat.nameLatin,
      surahId: int.parse(surat.number),
      ayahId: int.parse(surat.startAyat),
      isLoading: true,
      reciterId: reciter.id,
      reciterName: reciter.name,
    );

    final audioNotifier = ref.read(audioRecitationProvider.notifier);
    await audioNotifier.init(
      newAudioState,
      onSuccess: () async {
        state = state.copyWith(audioSuratLoaded: null);
        onSuccess();
      },
      onLoadError: () async {
        state = state.copyWith(audioSuratLoaded: null);
        onLoadError();
      },
      onPlayBackError: () async {
        state = state.copyWith(audioSuratLoaded: null);
        onPlayBackError();
      },
    );
  }

  Future<void> refreshDataOnPopFromSurahPage() async {
    final habitSvc = ref.read(habitDailySummaryService);
    final sp = ref.read(sharedPreferenceServiceProvider);

    final dailySummary = await habitSvc
        .getCurrentDayHabitDailySummaryListLocal();
    await _getLastBookmark();
    final lastRecordingData = await sp.getLastRecordingData();

    state = state.copyWith(
      dailySummary: dailySummary,
      lastRecordingData: lastRecordingData,
    );
  }

  Future<ForceLoginParam?> getAndRemoveForceLoginParam() async {
    final sp = ref.read(sharedPreferenceServiceProvider);
    final res = await sp.getForceLoginParam();
    if (res != null) await sp.removeForceLoginParam();
    return res;
  }

  void _getUsername() {
    final sp = ref.read(sharedPreferenceServiceProvider);
    final token = sp.getApiToken();
    final name = token.isEmpty ? '' : sp.getUsername();
    state = state.copyWith(name: name, token: token);
  }

  void _isNeedSync() {
    final isNeedSync = ref.read(habitDailySummaryService).isNeedSync();
    state = state.copyWith(isNeedSync: isNeedSync);
  }

  Future<void> _getVerseToAyahPage() async {
    final json = await rootBundle.loadString(AppConstants.ayahPageJson);
    state = state.copyWith(ayahPage: verseToPageJsonParse(json));
  }

  Future<void> _getJuzElements() async {
    final json = await rootBundle.loadString(AppConstants.jsonJuz);
    if (json.isEmpty) return;
    state = state.copyWith(juzElements: juzFromJson(json).juz);
  }

  Future<void> _getLastRecordingData() async {
    final data = await ref
        .read(sharedPreferenceServiceProvider)
        .getLastRecordingData();
    state = state.copyWith(lastRecordingData: data);
  }

  Future<void> _getDailySummary() async {
    final summary = await ref
        .read(habitDailySummaryService)
        .getCurrentDayHabitDailySummaryListLocal();
    state = state.copyWith(dailySummary: summary);
  }

  Future<void> _getLastBookmark() async {
    final result = await _db.getBookmarks(limit: 1);
    Bookmarks? lastBookmark;
    if (result != null && result.isNotEmpty) {
      lastBookmark = Bookmarks.fromMap(result[0]);
    }
    state = state.copyWith(lastBookmark: lastBookmark);
  }

  Future<void> _getTaddaburSurahAvaliable() async {
    final available = await _db.getTadabburSurahAvailable();
    final Map<int, int> map = {};
    for (var surah in available) {
      map[surah['id']] = surah['total_tadabbur'];
    }
    state = state.copyWith(listTaddaburAvailables: map);
  }
}
