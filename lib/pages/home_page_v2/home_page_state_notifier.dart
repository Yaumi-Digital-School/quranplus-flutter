import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/models/form.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
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
  });

  String token;
  String name;
  List<JuzElement>? juzElements;
  String? feedbackUrl;
  Map<String, List<String>>? ayahPage;
  HabitDailySummary? dailySummary;
  bool isNeedSync;

  HomePageState copyWith({
    String? token,
    String? name,
    List<JuzElement>? juzElements,
    String? feedbackUrl,
    Map<String, List<String>>? ayahPage,
    HabitDailySummary? dailySummary,
    bool? isNeedSync,
  }) {
    return HomePageState(
      token: token ?? this.token,
      name: name ?? this.name,
      juzElements: juzElements ?? this.juzElements,
      feedbackUrl: feedbackUrl ?? this.feedbackUrl,
      ayahPage: ayahPage ?? this.ayahPage,
      dailySummary: dailySummary ?? this.dailySummary,
      isNeedSync: isNeedSync ?? this.isNeedSync,
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

  @override
  Future<void> initStateNotifier() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    _getUsername();
    if (connectivityResult != ConnectivityResult.none) {
      _feedbackUrl = (await _fetchLink()).url ?? '';
    }
    await _getJuzElements();
    await _getVerseToAyahPage();

    if (_name?.isNotEmpty ?? false) {
      _habitDailySummaryService.syncHabit(
        connectivityResult: connectivityResult,
      );
    }
    final isNeedSync = _habitDailySummaryService.isNeedSync();

    _dailySummary = await _habitDailySummaryService
        .getCurrentDayHabitDailySummaryListLocal();

    state = state.copyWith(
      token: _token,
      name: _name,
      juzElements: _juzElements,
      feedbackUrl: _feedbackUrl ?? '',
      ayahPage: _ayahPage,
      dailySummary: _dailySummary,
      isNeedSync: isNeedSync,
    );
  }

  Future<void> getCurrentHabitDailySummaryListLocal() async {
    _dailySummary = await _habitDailySummaryService
        .getCurrentDayHabitDailySummaryListLocal();

    state = state.copyWith(dailySummary: _dailySummary);
  }

  Future<void> _getVerseToAyahPage() async {
    final String ayahPageJsonParse =
        await rootBundle.loadString(AppConstants.ayahPageJson);
    _ayahPage = verseToPageJsonParse(ayahPageJsonParse);
  }

  void _getUsername() {
    _token = _sharedPreferenceService.getApiToken();
    if (_token == null || _token!.isEmpty) {
      _name = '';

      return;
    }

    _name = _sharedPreferenceService.getUsername();
  }

  Future<void> _getJuzElements() async {
    final String jsonJuzInString =
        await rootBundle.loadString(AppConstants.jsonJuz);

    if (jsonJuzInString.isEmpty) {
      return;
    }

    _juzElements = juzFromJson(jsonJuzInString).juz;
  }

  Future<FormLink> _fetchLink() async {
    final response = await http
        .get(Uri.parse(EnvConstants.baseUrl! + '/api/resource/form-feedback'));

    if (response.statusCode == 200) {
      return FormLink.fromJson(jsonDecode(response.body));
    } else {
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
}
