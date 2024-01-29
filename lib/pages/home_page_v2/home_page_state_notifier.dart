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
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/audio.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/main_page_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_recitation_state_notifier.dart';

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

class HomePageStateNotifier extends BaseStateNotifier<HomePageState> {
  HomePageStateNotifier({
    required HabitDailySummaryService habitDailySummaryService,
    required SharedPreferenceService sharedPreferenceService,
    required this.mainPageProvider,
    required this.authenticationService,
    required AudioRecitationStateNotifier audioRecitationStateNotifier,
  })  : _sharedPreferenceService = sharedPreferenceService,
        _habitDailySummaryService = habitDailySummaryService,
        _audioRecitationNotifier = audioRecitationStateNotifier,
        super(HomePageState(isNeedSync: false));

  final SharedPreferenceService _sharedPreferenceService;
  final AuthenticationService authenticationService;
  final HabitDailySummaryService _habitDailySummaryService;
  final MainPageProvider mainPageProvider;
  late List<JuzElement> _juzElements;
  late Map<String, List<String>>? _ayahPage;
  bool loginBottomSheetAlreadyBuilt = false;
  String? _token, _name;
  HabitDailySummary? _dailySummary;
  late Map<int, int>? _listTaddaburAvailables;
  DbLocal db = DbLocal();

  final AudioRecitationStateNotifier _audioRecitationNotifier;

  Bookmarks? _lastBookmark;

  @override
  Future<void> initStateNotifier() async {
    try {
      _getUsername();
      _isNeedSync();
      _getVerseToAyahPage();
      _getJuzElements();
      _getLastRecordingData();
      _getLastBookmark();
      _getDailySummary();
      _getTaddaburSurahAvaliable();
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on initStateNotifier() method',
      );
    }
  }

  Future<void> initAyahAudio({
    required SuratByJuz surat,
    required Function() onSuccess,
    required Function() onLoadError,
    required Function() onPlayBackError,
  }) async {
    _setAudioSuratLoaded(surat);
    final ReciterItemResponse reciterItemResponse =
        await _sharedPreferenceService.getSelectedReciter();

    final AudioRecitationState newState = AudioRecitationState(
      surahName: surat.nameLatin,
      surahId: int.parse(surat.number),
      ayahId: int.parse(surat.startAyat),
      isLoading: true,
      reciterId: reciterItemResponse.id,
      reciterName: reciterItemResponse.name,
    );

    await _audioRecitationNotifier.init(
      newState,
      onSuccess: () async {
        _resetAudioSuratLoaded();
        onSuccess();
      },
      onLoadError: () async {
        _resetAudioSuratLoaded();
        onLoadError();
      },
      onPlayBackError: () async {
        _resetAudioSuratLoaded();
        onPlayBackError();
      },
    );
  }

  void _setAudioSuratLoaded(
    SuratByJuz surat,
  ) {
    state = state.copyWith(
      audioSuratLoaded: surat,
    );
  }

  void _resetAudioSuratLoaded() {
    state = state.copyWith(
      audioSuratLoaded: null,
    );
  }

  Future<void> _getLastRecordingData() async {
    final LastRecordingData? lastRecordingData =
        await _sharedPreferenceService.getLastRecordingData();

    state = state.copyWith(
      lastRecordingData: lastRecordingData,
    );
  }

  Future<void> _getDailySummary() async {
    _dailySummary = await _habitDailySummaryService
        .getCurrentDayHabitDailySummaryListLocal();

    state = state.copyWith(
      dailySummary: _dailySummary,
    );
  }

  Future<void> _getLastBookmark() async {
    final List<dynamic>? result = await db.getBookmarks(limit: 1);

    if (result != null && result.isNotEmpty) {
      _lastBookmark = Bookmarks.fromMap(result[0]);
    }

    state = state.copyWith(
      lastBookmark: _lastBookmark,
    );
  }

  Future<void> refreshDataOnPopFromSurahPage() async {
    _dailySummary = await _habitDailySummaryService
        .getCurrentDayHabitDailySummaryListLocal();

    await _getLastBookmark();
    final LastRecordingData? lastRecordingData =
        await _sharedPreferenceService.getLastRecordingData();

    state = state.copyWith(
      dailySummary: _dailySummary,
      lastBookmark: _lastBookmark,
      lastRecordingData: lastRecordingData,
    );
  }

  Future<void> _getVerseToAyahPage() async {
    final String ayahPageJsonParse =
        await rootBundle.loadString(AppConstants.ayahPageJson);
    _ayahPage = verseToPageJsonParse(ayahPageJsonParse);

    state = state.copyWith(
      ayahPage: _ayahPage,
    );
  }

  void _getUsername() {
    _token = _sharedPreferenceService.getApiToken();
    if (_token == null || _token!.isEmpty) {
      _name = '';
    } else {
      _name = _sharedPreferenceService.getUsername();
    }

    state = state.copyWith(
      name: _name,
    );
  }

  void _isNeedSync() {
    final bool isNeedSync = _habitDailySummaryService.isNeedSync();
    state = state.copyWith(
      isNeedSync: isNeedSync,
    );
  }

  Future<void> _getJuzElements() async {
    final String jsonJuzInString =
        await rootBundle.loadString(AppConstants.jsonJuz);

    if (jsonJuzInString.isEmpty) {
      return;
    }

    _juzElements = juzFromJson(jsonJuzInString).juz;

    state = state.copyWith(
      juzElements: _juzElements,
    );
  }

  Future<ForceLoginParam?> getAndRemoveForceLoginParam() async {
    final ForceLoginParam? res =
        await _sharedPreferenceService.getForceLoginParam();

    if (res != null) {
      await _sharedPreferenceService.removeForceLoginParam();
    }

    return res;
  }

  Future<void> _getTaddaburSurahAvaliable() async {
    List<dynamic> taddaburSurahAvailable = await db.getTadabburSurahAvailable();

    Map<int, int>? tadabburSurahMap = {};
    for (var surah in taddaburSurahAvailable) {
      tadabburSurahMap[surah['id']] = surah['total_tadabbur'];
    }
    _listTaddaburAvailables = tadabburSurahMap;

    state = state.copyWith(
      listTaddaburAvailables: _listTaddaburAvailables,
    );
  }
}
