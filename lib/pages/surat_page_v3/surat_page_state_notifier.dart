import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbBookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';

class SuratPageState {
  SuratPageState({
    this.pages,
    this.pageController,
    this.translations,
    this.tafsirs,
    this.latins,
    this.readingSettings,
    this.fullPageSeparators,
    this.isBookmarkFetched = false,
  });

  List<QuranPage>? pages;
  List<FullPageSeparator>? fullPageSeparators;
  List<List<String>>? translations;
  List<List<String>>? tafsirs;
  List<List<String>>? latins;
  PageController? pageController;
  ReadingSettings? readingSettings;
  int separatorBuilderIndex = 0;
  bool isBookmarkFetched;

  SuratPageState copyWith({
    List<QuranPage>? pages,
    List<FullPageSeparator>? fullPageSeparators,
    PageController? pageController,
    List<List<String>>? translations,
    List<List<String>>? tafsirs,
    List<List<String>>? latins,
    ReadingSettings? readingSettings,
    bool? isBookmarkFetched,
  }) {
    separatorBuilderIndex = 0;

    return SuratPageState(
      isBookmarkFetched: isBookmarkFetched ?? this.isBookmarkFetched,
      pages: pages ?? this.pages,
      pageController: pageController ?? this.pageController,
      translations: translations ?? this.translations,
      tafsirs: tafsirs ?? this.tafsirs,
      latins: latins ?? this.latins,
      readingSettings: readingSettings ?? this.readingSettings,
      fullPageSeparators: fullPageSeparators ?? this.fullPageSeparators,
    );
  }

  double get currentPage => pageController!.page!;

  bool get isLoading =>
      pages == null ||
      translations == null ||
      latins == null ||
      tafsirs == null ||
      readingSettings == null ||
      fullPageSeparators == null ||
      !isBookmarkFetched;
}

class SuratPageStateNotifier extends BaseStateNotifier<SuratPageState> {
  SuratPageStateNotifier({
    required this.startPageInIndex,
    required SharedPreferenceService sharedPreferenceService,
    required BookmarkApi bookmarkApi,
    bool isLoggedIn = false,
  })  : _sharedPreferenceService = sharedPreferenceService,
        _isLoggedIn = isLoggedIn,
        _bookmarkApi = bookmarkApi,
        super(SuratPageState());

  final SharedPreferenceService _sharedPreferenceService;
  final List<int> _firstPageSurahPointer = <int>[];
  final List<int> _bookmarkList = <int>[];

  List<int> get firstPageKeys => _firstPageSurahPointer;
  final BookmarkApi _bookmarkApi;
  final bool _isLoggedIn;
  late PageController pageController;
  int startPageInIndex;
  late DbBookmarks db;
  late List<QuranPage> _allPages;
  late List<FullPageSeparator> _fullPageSeparators;
  List<List<String>>? _translations;
  List<List<String>>? _tafsirs;
  List<List<String>>? _latins;
  late ValueNotifier<int> currentPage;
  late ValueNotifier<String> visibleSuratName;
  late ValueNotifier<int> visibleJuzNumber;
  late ValueNotifier<bool> visibleIconBookmark;
  List<int> currentVisibleSurahNumber = <int>[];
  late int temp;
  bool? _isBookmarkChanged;

  @override
  Future<void> initStateNotifier({
    ConnectivityResult? connectivityResult,
  }) async {
    db = DbBookmarks();
    _allPages = await getPages();
    pageController = PageController(
      initialPage: startPageInIndex,
    );
    final ReadingSettings settings =
        _sharedPreferenceService.getReadingSettings();
    Verse firstVerseInDirectedPage = _allPages[startPageInIndex].verses[0];
    temp = firstVerseInDirectedPage.surahNumber;
    currentPage = ValueNotifier(startPageInIndex + 1);
    visibleSuratName = ValueNotifier(
      surahNumberToSurahNameMap[firstVerseInDirectedPage.surahNumber]!,
    );
    visibleJuzNumber = ValueNotifier(
      firstVerseInDirectedPage.juzNumber,
    );
    visibleIconBookmark = ValueNotifier(false);

    await _getBookmarkListFromLocal();
    await _generateTranslations();
    await _generateLatins();
    await _generateBaseTafsirs();
    await _generateFullPageSeparators();

    state = state.copyWith(
      pages: _allPages,
      pageController: pageController,
      readingSettings: settings,
      translations: _translations,
      tafsirs: _tafsirs,
      latins: _latins,
      fullPageSeparators: _fullPageSeparators,
      isBookmarkFetched: true,
    );

    checkIsBookmarkExists(startPageInIndex + 1);
  }

  bool get isBookmarkChanged => _isBookmarkChanged ?? false;

  int getJuzAtStartOfPage({
    required int pageInIdx,
  }) {
    return _allPages[pageInIdx].verses[0].juzNumber;
  }

  String getSuratNameAtStartOfPage({
    required int pageInIdx,
  }) {
    return surahNumberToSurahNameMap[
        _allPages[pageInIdx].verses[0].surahNumber]!;
  }

  Future<void> _generateTranslations() async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_translations/indonesia.json'),
    );

    _translations = map
        .map(
          (e) => (e as List)
              .map(
                (e) => (e as String),
              )
              .toList(),
        )
        .toList();
  }

  Future<void> _generateFullPageSeparators() async {
    List<dynamic> separatorJson = await json.decode(
      await rootBundle.loadString('data/full_page_separator/separator.json'),
    );

    final FullPageSeparatorList fullPageSeparatorList =
        FullPageSeparatorList.fromArray(separatorJson);

    _fullPageSeparators = fullPageSeparatorList.separators;
  }

  Future<void> _generateLatins() async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_latins/latin.json'),
    );

    _latins = map
        .map(
          (e) => (e as List)
              .map(
                (e) => (e as String),
              )
              .toList(),
        )
        .toList();
  }

  Future<void> _generateBaseTafsirs() async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_tafsirs/indonesia_kemenag.json'),
    );

    _tafsirs = map
        .map(
          (e) => (e as List)
              .map(
                (e) => (e as String),
              )
              .toList(),
        )
        .toList();
  }

  Future<List<QuranPage>> getPages() async {
    const int quranPages = 604;
    List<QuranPage> pages = <QuranPage>[];

    for (int page = 1; page <= quranPages; page++) {
      QuranPage p = await _getPage(page);

      pages.add(p);
    }

    return pages;
  }

  Future<QuranPage> _getPage(int page) async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_pages/page$page.json'),
    );

    QuranPage qPage = QuranPage.fromArray(map);

    return qPage;
  }

  void setIsWithTranslations(bool value) {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isWithTranslations: value,
    );
    state = state.copyWith(readingSettings: settings);
    _sharedPreferenceService.setReadingSettings(settings);
  }

  void setIsWithTafsirs(bool value) {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isWithTafsirs: value,
    );

    state = state.copyWith(readingSettings: settings);

    _sharedPreferenceService.setReadingSettings(settings);
  }

  void setisWithLatins(bool value) {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isWithLatins: value,
    );

    state = state.copyWith(readingSettings: settings);

    _sharedPreferenceService.setReadingSettings(settings);
  }

  void minusFontSize(int fontSize) {
    ReadingSettings settings = state.readingSettings!.copyWith(
      fontSize: fontSize,
    );

    if (settings.fontSize >= 2) {
      settings.fontSize--;
      setValueFontSize(settings);
    }
    state = state.copyWith(readingSettings: settings);
    _sharedPreferenceService.setReadingSettings(settings);
  }

  void addFontSize(int fontSize) {
    ReadingSettings settings = state.readingSettings!.copyWith(
      fontSize: fontSize,
    );
    if (settings.fontSize <= 4) {
      settings.fontSize++;
      setValueFontSize(settings);
    }
    state = state.copyWith(readingSettings: settings);
    _sharedPreferenceService.setReadingSettings(settings);
  }

  void setValueFontSize(ReadingSettings readingSettings) {
    switch (readingSettings.fontSize) {
      case 1:
        readingSettings.valueFontSize = 12;
        readingSettings.valueFontSizeArabic = 24;
        readingSettings.valueFontSizeArabicFirstSheet = 35;
        break;
      case 2:
        readingSettings.valueFontSize = 16;
        readingSettings.valueFontSizeArabic = 36;
        readingSettings.valueFontSizeArabicFirstSheet = 47;
        break;
      case 3:
        readingSettings.valueFontSize = 20;
        readingSettings.valueFontSizeArabic = 40;
        readingSettings.valueFontSizeArabicFirstSheet = 51;
        break;
      case 4:
        readingSettings.valueFontSize = 24;
        readingSettings.valueFontSizeArabic = 44;
        readingSettings.valueFontSizeArabicFirstSheet = 55;
        break;
      case 5:
        readingSettings.valueFontSize = 28;
        readingSettings.valueFontSizeArabic = 48;
        readingSettings.valueFontSizeArabicFirstSheet = 59;
        break;
      default:
        break;
    }
  }

  void setIsInFullPage(bool isInFullPage) {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isInFullPage: isInFullPage,
    );

    state = state.copyWith(readingSettings: settings);
    _sharedPreferenceService.setReadingSettings(settings);
  }

  Future<void> insertBookmark(
    String surahName,
    int page,
    ConnectivityResult connectivityResult,
  ) async {
    if (connectivityResult != ConnectionState.none && _isLoggedIn) {
      await _toggleBookmark(
        surahName: surahName,
        page: page,
      );
    }

    await db.saveBookmark(
      Bookmarks(
        surahName: surahName,
        page: page,
      ),
    );

    _bookmarkList.add(page);
    visibleIconBookmark.value = true;
    _setIsBookmarkChanged();
  }

  Future<void> _toggleBookmark({
    required int page,
    String? surahName,
  }) async {
    try {
      HttpResponse<CreateBookmarkResponse> response =
          await _bookmarkApi.createBookmark(
              request: CreateBookmarkRequest(
        surahId: surahNameToSurahNumberMap[surahName],
        page: page,
      ));
    } catch (e) {
      // TODO(yumnanaruto): add logging here
    }
  }

  void checkIsBookmarkExists(int page) {
    final bool isExists = _bookmarkList.contains(page);
    if (isExists) {
      visibleIconBookmark.value = true;
      return;
    }

    visibleIconBookmark.value = false;
  }

  Future<void> _getBookmarkList() async {
    List<Bookmarks>? _listBookmark;

    HttpResponse<GetBookmarkListResponse> response =
        await _bookmarkApi.getBookmarkList();

    if (response.response.statusCode == 200) {
      _listBookmark = response.data.data;
      _listBookmark.forEach((bookmark) {
        _bookmarkList.add(bookmark.page);
      });
    }
  }

  Future<void> _getBookmarkListFromLocal() async {
    var result = await db.getAllBookmark();
    result!.forEach((bookmark) {
      _bookmarkList.add(
        Bookmarks.fromMap(bookmark).page,
      );
    });
  }

  @Deprecated('Please use checkIsBookmarkExists instead')
  Future<bool> checkOneBookmark(startPage) async {
    var result = await db.oneBookmark(startPage);
    if (result == false) {
      return visibleIconBookmark.value = false;
    } else {
      return visibleIconBookmark.value = true;
    }
  }

  Future<void> deleteBookmark(
    int page,
    ConnectivityResult connectivityResult,
  ) async {
    if (connectivityResult != ConnectivityResult.none && _isLoggedIn) {
      await _toggleBookmark(
        page: page,
      );
    }

    await db.deleteBookmark(page);

    visibleIconBookmark.value = false;
    _bookmarkList.removeWhere((pageInList) => pageInList == page);
    _setIsBookmarkChanged();
  }

  void _setIsBookmarkChanged() {
    _isBookmarkChanged = true;
  }

  void addFirstPagePointer(int value) {
    _firstPageSurahPointer.add(value);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
