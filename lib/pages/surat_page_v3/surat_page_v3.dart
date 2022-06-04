import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/bookmark_page.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_v2.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v2/surat_page_view_model.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_settings_drawer.dart';
import 'package:qurantafsir_flutter/shared/constants/app_icons.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/core/provider/surat_data_provider.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

enum AyahFontSize {
  big,
  regular,
}

extension AyahFontSizeExt on AyahFontSize {
  double get value {
    switch (this) {
      case AyahFontSize.big:
        return 35;
      case AyahFontSize.regular:
        return 26;
    }
  }
}

class SuratPageV3 extends StatefulWidget {
  const SuratPageV3({
    Key? key,
    required this.startPageInIndex,
    required this.firstPagePointerIndex,
    required this.namaSurat,
    required this.juz,
    this.bookmarks,
  }) : super(key: key);

  final String namaSurat;
  final int juz;
  final Bookmarks? bookmarks;
  final int startPageInIndex;
  final int firstPagePointerIndex;

  @override
  State<StatefulWidget> createState() {
    return _SuratPageV3State();
  }
}

class _SuratPageV3State extends State<SuratPageV3> {
  late AutoScrollController firstPageScrollController;

  @override
  void initState() {
    super.initState();
    firstPageScrollController = AutoScrollController();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) {
        Future.delayed(
          const Duration(milliseconds: 600),
          () {
            firstPageScrollController.scrollToIndex(
              widget.firstPagePointerIndex,
              preferPosition: AutoScrollPosition.begin,
              duration: const Duration(seconds: 1),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return ViewModelConnector<SuratPageViewModel, SuratPageState>(
      viewModelProvider:
          StateNotifierProvider<SuratPageViewModel, SuratPageState>(
        (ref) {
          return SuratPageViewModel(
            startPageInIndex: widget.startPageInIndex,
            namaSurat: widget.namaSurat,
            juz: widget.juz,
            bookmarks: widget.bookmarks,
            suratDataService: ref.watch(suratDataServiceProvider),
          );
        },
      ),
      onViewModelReady: (viewModel) async => await viewModel.initViewModel(),
      builder: (
        BuildContext context,
        SuratPageState state,
        SuratPageViewModel viewModel,
        _,
      ) {
        if (state.pages == null || state.translations == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              automaticallyImplyLeading: false,
              elevation: 2.5,
              foregroundColor: Colors.black,
              title: const Text('Surat'),
              backgroundColor: backgroundColor,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.bookmark_outline),
                  onPressed: () {
                    viewModel.insertBookmark(
                      widget.namaSurat,
                      widget.juz,
                      widget.startPageInIndex + 1,
                    );
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const BookmarkPageV2();
                    }));
                  },
                ),
                IconButton(
                  icon: const Icon(CustomIcons.book),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This is a Full Page')));
                  },
                ),
                IconButton(
                  icon: const Icon(CustomIcons.sliders),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPages(state: state),
          ),
          endDrawer: SuratPageSettingsDrawer(
            isWithTranslation: state.isWithTranslations,
            isWithTafsir: state.isWithTafsirs,
            onTapTranslation: (value) => viewModel.setIsWithTranslations(value),
            onTapTafsir: (value) => viewModel.setIsWithTafsirs(value),
          ),
        );
      },
    );
  }

  Widget _buildPages({
    required SuratPageState state,
  }) {
    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < state.pages!.length; idx++) {
      int pageNumberInQuran = idx + 1;

      Widget page = _buildPage(
        quranPageObject: state.pages![idx],
        pageNumberInQuran: pageNumberInQuran,
        state: state,
      );

      allPages.add(page);
    }

    return PageView(
      reverse: true,
      controller: state.pageController,
      children: allPages,
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required int pageNumberInQuran,
    required SuratPageState state,
  }) {
    final int pageNumberInQuranInIndex = pageNumberInQuran - 1;

    List<Widget> ayahs = <Widget>[];
    for (int i = 0; i < quranPageObject.verses.length; i++) {
      bool useDivider = i != quranPageObject.verses.length - 1;
      Verse verse = quranPageObject.verses[i];

      Widget w = _buildAyah(
        verse: verse,
        useDivider: useDivider,
        fontSize: pageNumberInQuran == 1 || pageNumberInQuran == 2
            ? AyahFontSize.big
            : AyahFontSize.regular,
        pageNumberInQuran: pageNumberInQuran,
        state: state,
      );

      ayahs.add(w);
    }

    return SingleChildScrollView(
      controller: pageNumberInQuranInIndex == widget.startPageInIndex
          ? firstPageScrollController
          : null,
      key: PageStorageKey('page$pageNumberInQuran'),
      child: Column(
        children: ayahs,
      ),
    );
  }

  Widget _buildAyah({
    required Verse verse,
    required bool useDivider,
    required AyahFontSize fontSize,
    required int pageNumberInQuran,
    required SuratPageState state,
  }) {
    String allVerses = '';
    String fontFamilyPage = 'Page$pageNumberInQuran';
    bool useBasmalahBeforeAyah = verse.verseNumber == 1;
    String translation =
        state.translations![verse.surahNumberInIndex][verse.verseNumberInIndex];
    bool isWithTranslations = state.isWithTranslations;

    for (Word word in verse.words) {
      allVerses += word.code + ' ';
    }

    return AutoScrollTag(
      key: ValueKey(verse.uniqueVerseIndex),
      controller: pageNumberInQuran - 1 == widget.startPageInIndex
          ? firstPageScrollController
          : AutoScrollController(),
      index: verse.uniqueVerseIndex,
      child: Column(
        children: <Widget>[
          if (useBasmalahBeforeAyah) _buildBasmalah(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                allVerses,
                style: TextStyle(
                  fontFamily: fontFamilyPage,
                  fontSize: fontSize.value,
                  height: 1.6,
                  wordSpacing: 2,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          if (isWithTranslations)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  translation,
                  style: bodyRegular3.merge(
                    const TextStyle(height: 1.5),
                  ),
                ),
              ),
            ),
          if (useDivider)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                height: 10,
                color: neutral400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBasmalah() {
    return Container(
      width: 165,
      height: 80,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'images/bismillah.png',
          ),
        ),
      ),
    );
  }
}
