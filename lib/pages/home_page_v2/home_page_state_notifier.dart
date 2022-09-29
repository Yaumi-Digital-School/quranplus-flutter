import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/pages/home_page.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/form.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/models/verse-topage.dart';
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
  });

  String token;
  String name;
  List<JuzElement>? juzElements;
  String? feedbackUrl;
  Map<String, List<String>>? ayahPage;

  HomePageState copyWith({
    String? token,
    String? name,
    List<JuzElement>? juzElements,
    String? feedbackUrl,
    Map<String, List<String>>? ayahPage,
  }) {
    return HomePageState(
        token: token ?? this.token,
        name: name ?? this.name,
        juzElements: juzElements ?? this.juzElements,
        feedbackUrl: feedbackUrl ?? this.feedbackUrl,
        ayahPage: ayahPage ?? this.ayahPage);
  }
}

class HomePageStateNotifier extends BaseStateNotifier<HomePageState> {
  HomePageStateNotifier({
    required SharedPreferenceService sharedPreferenceService,
  })  : _sharedPreferenceService = sharedPreferenceService,
        super(HomePageState());

  final SharedPreferenceService _sharedPreferenceService;
  late List<JuzElement> _juzElements;
  late Map<String, List<String>>? _ayahPage;
  String? _token, _name, _feedbackUrl;

  @override
  Future<void> initStateNotifier() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    _getUsername();
    await _getJuzElements();
    await _getVerseToAyahPage();
    if (connectivityResult != ConnectivityResult.none) {
      _feedbackUrl = (await _fetchLink()).url ?? '';
    }

    state = state.copyWith(
        token: _token,
        name: _name,
        juzElements: _juzElements,
        feedbackUrl: _feedbackUrl ?? '',
        ayahPage: _ayahPage);
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
}
