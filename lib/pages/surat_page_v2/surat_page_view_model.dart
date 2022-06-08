import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbBookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/core/services/surat_data_service.dart';
import 'package:qurantafsir_flutter/shared/core/view_models/base_view_model.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

class SuratPageState {
  SuratPageState({
    this.bookmarks,
    this.pages,
    this.pageController,
    this.translations,
    this.tafsirs,
    this.isWithTafsirs = false,
    this.isWithTranslations = true,
  });

  Bookmarks? bookmarks;
  List<QuranPage>? pages;
  List<List<String>>? translations;
  List<List<String>>? tafsirs;
  PageController? pageController;
  bool isWithTranslations;
  bool isWithTafsirs;

  SuratPageState copyWith({
    Bookmarks? bookmarks,
    List<QuranPage>? pages,
    PageController? pageController,
    List<List<String>>? translations,
    List<List<String>>? tafsirs,
    bool? isWithTranslations,
    bool? isWithTafsirs,
  }) {
    return SuratPageState(
      bookmarks: bookmarks ?? this.bookmarks,
      pages: pages ?? this.pages,
      pageController: pageController ?? this.pageController,
      translations: translations ?? this.translations,
      tafsirs: tafsirs ?? this.tafsirs,
      isWithTafsirs: isWithTafsirs ?? this.isWithTafsirs,
      isWithTranslations: isWithTranslations ?? this.isWithTranslations,
    );
  }

  double get currentPage => pageController!.page!;
}

class SuratPageViewModel extends BaseViewModel<SuratPageState> {
  SuratPageViewModel({
    required this.startPageInIndex,
    required SuratDataService suratDataService,
    this.bookmarks,
  })  : _suratDataService = suratDataService,
        super(
          SuratPageState(
            bookmarks: bookmarks,
          ),
        );

  Bookmarks? bookmarks;
  final SuratDataService _suratDataService;
  final List<int> _firstPageSurahPointer = <int>[];
  List<int> get firstPageKeys => _firstPageSurahPointer;
  late PageController pageController;
  int startPageInIndex;
  late DbBookmarks db;
  late List<QuranPage> allPages;
  List<List<String>>? _translations;
  List<List<String>>? _tafsirs;
  late ValueNotifier<int> currentPage;
  late ValueNotifier<String> visibleSuratName;
  late ValueNotifier<int> visibleJuzNumber;
  List<int> currentVisibleSurahNumber = <int>[];
  late int temp;

  @override
  Future<void> initViewModel() async {
    db = DbBookmarks();
    allPages = await getPages();
    pageController = PageController(
      initialPage: startPageInIndex,
    );
    state = state.copyWith(
      pages: allPages,
      pageController: pageController,
    );
    Verse firstVerseInDirectedPage = allPages[startPageInIndex].verses[0];
    temp = firstVerseInDirectedPage.surahNumber;
    currentPage = ValueNotifier(startPageInIndex + 1);
    visibleSuratName = ValueNotifier(
        surahNumberToSurahNameMap[firstVerseInDirectedPage.surahNumber]!);
    visibleJuzNumber = ValueNotifier(firstVerseInDirectedPage.juzNumber);
    await _generateTranslations();
    await _generateBaseTafsirs();
  }

  int getJuzAtStartOfPage({
    required int pageInIdx,
  }) {
    return allPages[pageInIdx].verses[0].juzNumber;
  }

  String getSuratNameAtStartOfPage({
    required int pageInIdx,
  }) {
    return surahNumberToSurahNameMap[
        allPages[pageInIdx].verses[0].surahNumber]!;
  }

  Future<void> _generateTranslations() async {
    if (_suratDataService.translations.isEmpty) {
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

      _suratDataService.setTranslations(_translations ?? []);
    } else {
      _translations = _suratDataService.translations;
    }

    state = state.copyWith(translations: _translations);
  }

  Future<void> _generateBaseTafsirs() async {
    if (_suratDataService.tafsirs.isEmpty) {
      List<dynamic> map = await json.decode(
        await rootBundle
            .loadString('data/quran_tafsirs/indonesia_kemenag.json'),
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

      _suratDataService.setTafsirs(_tafsirs ?? []);
    } else {
      _tafsirs = _suratDataService.tafsirs;
    }

    state = state.copyWith(tafsirs: _tafsirs);
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
    state = state.copyWith(isWithTranslations: value);
  }

  void setIsWithTafsirs(bool value) {
    state = state.copyWith(isWithTafsirs: value);
  }

  Future<void> insertBookmark(namaSurat, juz, page) async {
    await db
        .saveBookmark(Bookmarks(namaSurat: namaSurat, juz: juz, page: page));
  }

  onGoBack(context) {
    state = state.copyWith();
    Navigator.pop(context);
  }

  void addFirstPagePointer(int value) {
    _firstPageSurahPointer.add(value);
  }
}
