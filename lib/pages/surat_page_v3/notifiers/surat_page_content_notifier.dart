import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_tadabbur_ayah_available.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'surat_page_content_notifier.g.dart';

@riverpod
class SuratPageContentNotifier extends _$SuratPageContentNotifier {
  final DbLocal _db = DbLocal();
  List<List<String>>? _translations;
  List<List<String>>? _tafsirs;
  List<List<String>>? _latins;
  int _currentFontSize = 1;

  SharedPreferenceService get _sharedPref =>
      ref.read(sharedPreferenceServiceProvider);

  @override
  SuratPageContentState build() => SuratPageContentState();

  Future<void> load(int startPageInIndex) async {
    final pages = await _getPages();
    final settings = _sharedPref.getReadingSettings();

    await _getTadabburAyahAvailable();

    if (settings.isWithTranslations) await _generateTranslations();
    if (settings.isWithLatins) await _generateLatins();
    if (settings.isWithTafsirs) await _generateBaseTafsirs();

    final separators = await _getFullPageSeparators();

    state = SuratPageContentState(
      pages: pages,
      fullPageSeparators: separators,
      translations: _translations,
      tafsirs: _tafsirs,
      latins: _latins,
      readingSettings: settings,
      availableAyahTadabburs: state.availableAyahTadabburs,
    );
  }

  Future<void> _getTadabburAyahAvailable() async {
    final Map<int, List<int>> result = {};
    final List<dynamic> res = await _db.getTadabburAyahAvailables();
    for (int i = 0; i < res.length; i++) {
      final int surahID = res[i][TadabburAyahAvailableTable.surahID];
      final String listOfAyahInStr =
          res[i][TadabburAyahAvailableTable.listOfAyahInStr];
      final List<dynamic> listOfAyah = json.decode(listOfAyahInStr);
      result[surahID] = List<int>.from(listOfAyah);
    }
    state = state.copyWith(availableAyahTadabburs: result);
  }

  Future<List<QuranPage>> _getPages() async {
    const int quranPages = 604;
    List<QuranPage> pages = <QuranPage>[];
    for (int page = 1; page <= quranPages; page++) {
      pages.add(await _getPage(page));
    }
    return pages;
  }

  Future<QuranPage> _getPage(int page) async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_pages/page$page.json'),
    );
    return QuranPage.fromArray(map);
  }

  Future<List<FullPageSeparator>> _getFullPageSeparators() async {
    List<dynamic> separatorJson = await json.decode(
      await rootBundle.loadString('data/full_page_separator/separator.json'),
    );
    return FullPageSeparatorList.fromArray(separatorJson).separators;
  }

  Future<void> _generateTranslations() async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_translations/indonesia.json'),
    );
    _translations = map
        .map((e) => (e as List).map((e) => (e as String)).toList())
        .toList();
  }

  Future<void> _generateLatins() async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_latins/latin.json'),
    );
    _latins = map
        .map((e) => (e as List).map((e) => (e as String)).toList())
        .toList();
  }

  Future<void> _generateBaseTafsirs() async {
    List<dynamic> map = await json.decode(
      await rootBundle
          .loadString('data/quran_tafsirs/indonesia_kemenag.json'),
    );
    _tafsirs = map
        .map((e) => (e as List).map((e) => (e as String)).toList())
        .toList();
  }

  Future<void> setIsWithTranslations(bool value) async {
    final settings =
        state.readingSettings!.copyWith(isWithTranslations: value);
    if (state.translations == null || state.translations!.isEmpty) {
      await _generateTranslations();
    }
    state =
        state.copyWith(readingSettings: settings, translations: _translations);
    _sharedPref.setReadingSettings(settings);
  }

  Future<void> setIsWithTafsirs(bool value) async {
    final settings = state.readingSettings!.copyWith(isWithTafsirs: value);
    if (state.tafsirs == null || state.tafsirs!.isEmpty) {
      await _generateBaseTafsirs();
    }
    state = state.copyWith(readingSettings: settings, tafsirs: _tafsirs);
    _sharedPref.setReadingSettings(settings);
  }

  Future<void> setIsWithLatins(bool value) async {
    final settings = state.readingSettings!.copyWith(isWithLatins: value);
    if (state.latins == null || state.latins!.isEmpty) {
      await _generateLatins();
    }
    state = state.copyWith(readingSettings: settings, latins: _latins);
    _sharedPref.setReadingSettings(settings);
  }

  void minusFontSize() {
    ReadingSettings settings = state.readingSettings!;
    if (settings.fontSize >= 2) settings.fontSize--;
    _setValueFontSize(settings);
    state = state.copyWith(readingSettings: settings);
    _sharedPref.setReadingSettings(settings);
  }

  void addFontSize() {
    ReadingSettings settings = state.readingSettings!;
    if (settings.fontSize <= 4) settings.fontSize++;
    _setValueFontSize(settings);
    state = state.copyWith(readingSettings: settings);
    _sharedPref.setReadingSettings(settings);
  }

  void _setValueFontSize(ReadingSettings readingSettings) {
    if (_currentFontSize != readingSettings.fontSize) {
      _currentFontSize = readingSettings.fontSize;
      switch (readingSettings.fontSize) {
        case 1:
          readingSettings.valueFontSize = 12;
          readingSettings.valueFontSizeArabic = 24;
          readingSettings.valueFontSizeArabicFirstSheet = 35;
          readingSettings.valueFontSizeLandscape = 16;
          readingSettings.valueFontSizeArabicLandscape = 36;
          readingSettings.valueFontSizeArabicFirstSheetLandscape = 47;
          break;
        case 2:
          readingSettings.valueFontSize = 16;
          readingSettings.valueFontSizeArabic = 36;
          readingSettings.valueFontSizeArabicFirstSheet = 47;
          readingSettings.valueFontSizeLandscape = 20;
          readingSettings.valueFontSizeArabicLandscape = 40;
          readingSettings.valueFontSizeArabicFirstSheetLandscape = 51;
          break;
        case 3:
          readingSettings.valueFontSize = 20;
          readingSettings.valueFontSizeArabic = 40;
          readingSettings.valueFontSizeArabicFirstSheet = 51;
          readingSettings.valueFontSizeLandscape = 24;
          readingSettings.valueFontSizeArabicLandscape = 44;
          readingSettings.valueFontSizeArabicFirstSheetLandscape = 55;
          break;
        case 4:
          readingSettings.valueFontSize = 24;
          readingSettings.valueFontSizeArabic = 44;
          readingSettings.valueFontSizeArabicFirstSheet = 55;
          readingSettings.valueFontSizeLandscape = 28;
          readingSettings.valueFontSizeArabicLandscape = 48;
          readingSettings.valueFontSizeArabicFirstSheetLandscape = 63;
          break;
        case 5:
          readingSettings.valueFontSize = 28;
          readingSettings.valueFontSizeArabic = 48;
          readingSettings.valueFontSizeArabicFirstSheet = 59;
          readingSettings.valueFontSizeLandscape = 32;
          readingSettings.valueFontSizeArabicLandscape = 52;
          readingSettings.valueFontSizeArabicFirstSheetLandscape = 59;
          break;
        default:
          break;
      }
    }
  }

  void setIsInFullPage(bool isInFullPage) {
    final settings =
        state.readingSettings!.copyWith(isInFullPage: isInFullPage);
    state = state.copyWith(readingSettings: settings);
    _sharedPref.setReadingSettings(settings);
    ref.read(suratPageNavigationProvider.notifier).recreatePageController();
  }

}
