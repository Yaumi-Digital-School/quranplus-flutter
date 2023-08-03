import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';

import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/form.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/models/last_recording_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/verse-topage.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/main_page_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:http/http.dart' as http;

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
    );
  }
}

class HomePageStateNotifier extends BaseStateNotifier<HomePageState> {
  HomePageStateNotifier({
    required HabitDailySummaryService habitDailySummaryService,
    required SharedPreferenceService sharedPreferenceService,
    required this.mainPageProvider,
    required this.authenticationService,
  })  : _sharedPreferenceService = sharedPreferenceService,
        _habitDailySummaryService = habitDailySummaryService,
        super(HomePageState(isNeedSync: false));

  final SharedPreferenceService _sharedPreferenceService;
  final AuthenticationService authenticationService;
  final HabitDailySummaryService _habitDailySummaryService;
  final MainPageProvider mainPageProvider;
  late List<JuzElement> _juzElements;
  late Map<String, List<String>>? _ayahPage;
  bool loginBottomSheetAlreadyBuilt = false;
  String? _token, _name, _feedbackUrl;
  HabitDailySummary? _dailySummary;
  late Map<int, int>? _listTaddaburAvailables;
  DbLocal db = DbLocal();

  Bookmarks? _lastBookmark;

  @override
  Future<void> initStateNotifier() async {
    try {
      _getUsername();
      _isNeedSync();
      await _getFeedbackUrl();
      await _getVerseToAyahPage();
      await _getJuzElements();
      await _getLastBookmark();
      await _getDailySummary();
      await _getLastRecordingData();
      await _getTaddaburSurahAvaliable();
    } catch (e) {
      print(e);
    }
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

  Future<void> _getFeedbackUrl() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      try {
        _feedbackUrl = (await _fetchLink()).url ?? '';
      } catch (e) {
        _feedbackUrl = "";
      }
    }

    state = state.copyWith(
      feedbackUrl: _feedbackUrl,
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

  Future<FormLink> _fetchLink() async {
    try {
      final response = await http.get(
        Uri.parse(EnvConstants.baseUrl! + '/api/resource/form-feedback'),
      );

      if (response.statusCode == 200) {
        return FormLink.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load form link');
      }
    } catch (e) {
      throw Exception('Failed to load form link');
    }
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
    List<dynamic> taddaburSurahAvailable = await db.GetTadabburSurahAvailable();

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
