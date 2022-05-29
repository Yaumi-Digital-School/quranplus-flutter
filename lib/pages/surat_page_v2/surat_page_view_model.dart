import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/core/view_models/base_view_model.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

class SuratPageState {
  SuratPageState({
    this.bookmarks,
    this.pages,
    this.pageController,
  });

  Bookmarks? bookmarks;
  List<QuranPage>? pages;
  PageController? pageController;

  SuratPageState copyWith({
    Bookmarks? bookmarks,
    List<QuranPage>? pages,
    PageController? pageController,
  }) {
    return SuratPageState(
      bookmarks: bookmarks ?? this.bookmarks,
      pages: pages ?? this.pages,
      pageController: pageController ?? this.pageController,
    );
  }

  double get currentPage => pageController!.page!;
}

class SuratPageViewModel extends BaseViewModel<SuratPageState> {
  SuratPageViewModel({
    required this.startPage,
    this.bookmarks,
  }) : super(SuratPageState(
          bookmarks: bookmarks,
          pageController: PageController(
            initialPage: startPage,
          ),
        ));

  Bookmarks? bookmarks;
  int startPage;
  late DbHelper db;
  late List<QuranPage> allPages;

  @override
  Future<void> initViewModel() async {
    db = DbHelper();
    allPages = await getPages();
    state = state.copyWith(pages: allPages);
  }

  Future<List<QuranPage>> getPages() async {
    const int quranPages = 604;
    List<QuranPage> pages = <QuranPage>[];

    for (int page = 1; page <= quranPages; page++) {
      QuranPage p = await getPage(page);

      pages.add(p);
    }

    return pages;
  }

  Future<QuranPage> getPage(int page) async {
    List<dynamic> map = await json.decode(
      await rootBundle.loadString('data/quran_pages/page$page.json'),
    );

    QuranPage qPage = QuranPage.fromArray(map);

    return qPage;
  }

  onGoBack(context) {
    state = state.copyWith();
    Navigator.pop(context);
  }
}
