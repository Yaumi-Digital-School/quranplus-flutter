import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page.dart';
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
    this.isWithTafsirs = false,
    this.isWithTranslations = true,
  });

  Bookmarks? bookmarks;
  List<QuranPage>? pages;
  List<List<String>>? translations;
  PageController? pageController;
  bool isWithTranslations;
  bool isWithTafsirs;

  SuratPageState copyWith({
    Bookmarks? bookmarks,
    List<QuranPage>? pages,
    PageController? pageController,
    List<List<String>>? translations,
    bool? isWithTranslations,
    bool? isWithTafsirs,
  }) {
    return SuratPageState(
      bookmarks: bookmarks ?? this.bookmarks,
      pages: pages ?? this.pages,
      pageController: pageController ?? this.pageController,
      translations: translations ?? this.translations,
      isWithTafsirs: isWithTafsirs ?? this.isWithTafsirs,
      isWithTranslations: isWithTranslations ?? this.isWithTranslations,
    );
  }

  double get currentPage => pageController!.page!;
}

class SuratPageViewModel extends BaseViewModel<SuratPageState> {
  SuratPageViewModel({
    required this.startPageInIndex,
    required this.namaSurat,
    required this.juz,
    required SuratDataService suratDataService,
    this.bookmarks,
  })  : _suratDataService = suratDataService,
        super(
          SuratPageState(
            bookmarks: bookmarks,
            pageController: PageController(
              initialPage: startPageInIndex,
            ),
          ),
        );

  Bookmarks? bookmarks;
  final SuratDataService _suratDataService;
  final List<int> _firstPageSurahPointer = <int>[];
  List<int> get firstPageKeys => _firstPageSurahPointer;
  int startPageInIndex;
  String namaSurat;
  int juz;
  late DbBookmarks db;
  late List<QuranPage> allPages;
  List<List<String>>? translations;

  @override
  Future<void> initViewModel() async {
    setBusy(true);
    db = DbBookmarks();
    allPages = await getPages();
    state = state.copyWith(pages: allPages);
    await _generateTranslations();
    setBusy(false);
  }

  Future<void> _generateTranslations() async {
    if (_suratDataService.translations.isEmpty) {
      List<dynamic> map = await json.decode(
        await rootBundle.loadString('data/quran_translations/indonesia.json'),
      );

      translations = map
          .map(
            (e) => (e as List)
                .map(
                  (e) => (e as String),
                )
                .toList(),
          )
          .toList();

      _suratDataService.setTranslations(translations ?? []);
    } else {
      translations = _suratDataService.translations;
    }

    state = state.copyWith(translations: translations);
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
