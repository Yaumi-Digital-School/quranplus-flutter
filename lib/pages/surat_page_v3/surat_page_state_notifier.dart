import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/apis/bookmark_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_tadabbur_ayah_available.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/bookmarks_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
    this.isRecording = false,
    this.isLoading = true,
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
  bool isRecording;
  bool isLoading;

  SuratPageState copyWith({
    List<QuranPage>? pages,
    List<FullPageSeparator>? fullPageSeparators,
    PageController? pageController,
    List<List<String>>? translations,
    List<List<String>>? tafsirs,
    List<List<String>>? latins,
    ReadingSettings? readingSettings,
    bool? isBookmarkFetched,
    bool? isRecording,
    bool? isLoading,
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
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  SuratPageState refresh() {
    return copyWith();
  }

  double get currentPage => pageController!.page!;
}

class SuratPageStateNotifier extends BaseStateNotifier<SuratPageState> {
  SuratPageStateNotifier({
    required this.startPageInIndex,
    required SharedPreferenceService sharedPreferenceService,
    required AuthenticationService authenticationService,
    required HabitDailySummaryService habitDailySummaryService,
    required BookmarkApi bookmarkApi,
    required BookmarksService bookmarksService,
    required AutoScrollController scrollController,
    bool isLoggedIn = false,
  })  : _sharedPreferenceService = sharedPreferenceService,
        _isLoggedIn = isLoggedIn,
        _bookmarkApi = bookmarkApi,
        _bookmarksService = bookmarksService,
        _scrollController = scrollController,
        _authenticationService = authenticationService,
        _habitDailySummaryService = habitDailySummaryService,
        super(SuratPageState());

  final AutoScrollController _scrollController;
  final SharedPreferenceService _sharedPreferenceService;
  final HabitDailySummaryService _habitDailySummaryService;
  final List<int> _firstPageSurahPointer = <int>[];
  final List<int> _bookmarkList = <int>[];
  final List<int> _favoriteAyahList = <int>[];

  SharedPreferenceService get sharedPreferenceService =>
      _sharedPreferenceService;
  final AuthenticationService _authenticationService;
  bool get isLoggedIn => _authenticationService.isLoggedIn;
  List<int> get firstPageKeys => _firstPageSurahPointer;
  final BookmarkApi _bookmarkApi;
  final BookmarksService _bookmarksService;
  final bool _isLoggedIn;
  late PageController pageController;
  int startPageInIndex;
  DbLocal db = DbLocal();
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
  bool? _isFavoriteAyahChanged;
  bool? _isHabitDailySummaryChanged;

  ValueNotifier<int> recordedPagesAsRead = ValueNotifier(0);
  List<int> recordedPagesList = <int>[];
  int _startPageOnRecord = 0;
  TextEditingController habitTrackerSubmissionController =
      TextEditingController();

  ValueNotifier<bool> isOnReadCTAVisible = ValueNotifier(true);
  double _scrollDownOffset = 0;
  double _scrollUpOffset = 0;

  final Map<int, List<int>> _availableAyahTadabburs = {};
  Map<int, List<int>> get availableAyahTadabburs => _availableAyahTadabburs;

  @override
  Future<void> initStateNotifier({
    ConnectivityResult? connectivityResult,
  }) async {
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

    await _getTadabburAyahAvailable();

    await _getBookmarkListFromLocal();
    await _getFavoriteListFromLocal();
    if (settings.isWithTranslations) {
      await _generateTranslations();
    }

    if (settings.isWithLatins) {
      await _generateLatins();
    }

    if (settings.isWithTafsirs) {
      await _generateBaseTafsirs();
    }

    await _generateFullPageSeparators();

    _scrollController.addListener(() => _listenOnScrollChanges());

    state = state.copyWith(
      pages: _allPages,
      pageController: pageController,
      readingSettings: settings,
      translations: _translations,
      tafsirs: _tafsirs,
      latins: _latins,
      fullPageSeparators: _fullPageSeparators,
      isBookmarkFetched: true,
      isLoading: false,
    );

    checkIsBookmarkExists(startPageInIndex + 1);
  }

  Future<void> _getTadabburAyahAvailable() async {
    final List<dynamic> res = await db.getTadabburAyahAvailables();

    for (int i = 0; i < res.length; i++) {
      final int surahID = res[i][TadabburAyahAvailableTable.surahID];
      final String listOfAyahInStr =
          res[i][TadabburAyahAvailableTable.listOfAyahInStr];
      final List<dynamic> listOfAyah = json.decode(listOfAyahInStr);

      _availableAyahTadabburs[surahID] = List<int>.from(listOfAyah);
    }
  }

  void _listenOnScrollChanges() {
    final double currentOffset = _scrollController.offset;
    final bool onScrollUpChecking = (_scrollUpOffset - currentOffset >= 150) &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;
    final bool onScrollDownChecking =
        (currentOffset - _scrollDownOffset >= 150) &&
            _scrollController.position.userScrollDirection ==
                ScrollDirection.reverse;

    if (onScrollUpChecking) {
      if (!isOnReadCTAVisible.value) {
        isOnReadCTAVisible.value = true;
      }

      _scrollDownOffset = currentOffset;
    }

    if (onScrollDownChecking) {
      if (isOnReadCTAVisible.value) {
        isOnReadCTAVisible.value = false;
      }

      _scrollUpOffset = currentOffset;
    }
  }

  void changePageOnRecording(int page) {
    final int addedPage = page - 1;
    if (addedPage < _startPageOnRecord) {
      return;
    }

    if (recordedPagesList.isEmpty) {
      if (_startPageOnRecord > 0) {
        recordedPagesList.add(addedPage);
        recordedPagesAsRead.value += 1;
      }

      return;
    }

    if (recordedPagesList.contains(addedPage)) {
      return;
    }

    recordedPagesList.add(addedPage);
    recordedPagesAsRead.value += 1;
  }

  bool isAyahFavorited(int ayahID) {
    return _favoriteAyahList.contains(ayahID);
  }

  bool get isBookmarkChanged => _isBookmarkChanged ?? false;
  bool get isFavoriteAyahChanged => _isFavoriteAyahChanged ?? false;
  bool get isHabitDailySummaryChanged => _isHabitDailySummaryChanged ?? false;

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

  Future<void> setIsWithTranslations(bool value) async {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isWithTranslations: value,
    );

    if (state.translations == null || state.translations!.isEmpty) {
      await _generateTranslations();
    }

    state = state.copyWith(
      readingSettings: settings,
      translations: _translations,
    );

    _sharedPreferenceService.setReadingSettings(settings);
  }

  Future<void> setIsWithTafsirs(bool value) async {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isWithTafsirs: value,
    );

    if (state.tafsirs == null || state.tafsirs!.isEmpty) {
      await _generateBaseTafsirs();
    }

    state = state.copyWith(
      readingSettings: settings,
      tafsirs: _tafsirs,
    );

    _sharedPreferenceService.setReadingSettings(settings);
  }

  Future<void> setisWithLatins(bool value) async {
    final ReadingSettings settings = state.readingSettings!.copyWith(
      isWithLatins: value,
    );

    if (state.latins == null || state.latins!.isEmpty) {
      await _generateLatins();
    }

    state = state.copyWith(
      readingSettings: settings,
      latins: _latins,
    );

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

    final int currentPageIndex = currentPage.value - 1;

    state = state.copyWith(
      readingSettings: settings,
      pageController: PageController(
        initialPage: currentPageIndex,
      ),
    );
    _sharedPreferenceService.setReadingSettings(settings);
  }

  Future<void> insertBookmark(
    String surahName,
    int page,
    ConnectivityResult connectivityResult,
  ) async {
    await db.saveBookmark(
      Bookmarks(
        surahName: surahName,
        page: page,
      ),
    );

    if (connectivityResult != ConnectionState.none && _isLoggedIn) {
      _toggleBookmark(
        surahName: surahName,
        page: page,
      );
    }

    if (connectivityResult == ConnectionState.none) {
      _bookmarksService.setIsMerged(false);
    }

    _bookmarkList.add(page);
    visibleIconBookmark.value = true;
    _setIsBookmarkChanged();
  }

  Future<void> _toggleBookmark({
    required int page,
    String? surahName,
  }) async {
    try {
      Future<HttpResponse<CreateBookmarkResponse>> _ =
          _bookmarkApi.createBookmark(
        request: CreateBookmarkRequest(
          surahId: surahNameToSurahNumberMap[surahName],
          page: page,
        ),
      );
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

  Future<void> _getBookmarkListFromLocal() async {
    var result = await db.getAllBookmark();
    for (var bookmark in result!) {
      _bookmarkList.add(
        Bookmarks.fromMap(bookmark).page,
      );
    }
  }

  Future<void> _getFavoriteListFromLocal() async {
    List<FavoriteAyahs> result = await db.getAllFavoriteAyahs();
    for (FavoriteAyahs favorite in result) {
      _favoriteAyahList.add(favorite.ayahHashCode);
    }
  }

  Future<void> toggleFavoriteAyah({
    required int surahNumber,
    required int ayahNumber,
    required int ayahID,
    required int page,
    required ConnectivityResult connectivityResult,
  }) async {
    if (isAyahFavorited(ayahID)) {
      await _deleteFavoriteAyah(ayahID);
    } else {
      await _insertFavoriteAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        ayahID: ayahID,
        page: page,
        connectivityResult: connectivityResult,
      );
    }

    _setIsFavoriteAyahChanged();
    state = state.refresh();
  }

  Future<void> _deleteFavoriteAyah(int ayahID) async {
    await db.deleteFavoriteAyahs(ayahID);
    _favoriteAyahList.removeWhere((item) => item == ayahID);
  }

  Future<void> _insertFavoriteAyah({
    required int surahNumber,
    required int ayahNumber,
    required int ayahID,
    required int page,
    required ConnectivityResult connectivityResult,
  }) async {
    await db.saveFavoriteAyahs(
      FavoriteAyahs(
        surahId: surahNumber,
        page: page,
        ayahSurah: ayahNumber,
        ayahHashCode: ayahID,
      ),
    );

    _favoriteAyahList.add(ayahID);
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

  int get habitDailyTarget => _currentSummary?.target ?? 0;

  HabitDailySummary? _currentSummary;
  Future<void> startRecording() async {
    _currentSummary = await db.getCurrentDayHabitDailySummary();

    recordedPagesAsRead.value = _currentSummary?.totalPages ?? 0;
    _startPageOnRecord = currentPage.value;

    state = state.copyWith(isRecording: true);
  }

  Future<bool> stopRecording() async {
    state = state.copyWith(isRecording: false);
    final int currentRecordedReadPages =
        int.parse(habitTrackerSubmissionController.value.text);

    if (currentRecordedReadPages > 0) {
      await db.submitHabitProgressWithDailySummaryByTracking(
        pages: currentRecordedReadPages,
        startPage: _startPageOnRecord,
        summary: _currentSummary!,
      );

      recordedPagesList.clear();
      _isHabitDailySummaryChanged = true;
    }

    _startPageOnRecord = 0;
    final int totalReadPages =
        currentRecordedReadPages + (_currentSummary!.totalPages);

    _habitDailySummaryService.syncHabit();

    if (totalReadPages >= (_currentSummary!.target)) {
      return true;
    }

    return false;
  }

  void _setIsBookmarkChanged() {
    _isBookmarkChanged = true;
  }

  void _setIsFavoriteAyahChanged() {
    _isFavoriteAyahChanged = true;
  }

  void addFirstPagePointer(int value) {
    _firstPageSurahPointer.add(value);
  }

  void forceLoginToEnableHabit(
    BuildContext context,
    String redirectTo,
    Map<String, dynamic> arguments,
  ) {
    _authenticationService.forceLoginAndSaveRedirectTo(
      context: context,
      redirectTo: redirectTo,
      arguments: arguments,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
