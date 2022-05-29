import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/bookmark_page.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_v2.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v2/surat_page_view_model.dart';
import 'package:qurantafsir_flutter/shared/constants/app_icons.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

enum AyahFontSize {
  big,
  regular,
}

extension AyahFontSizeExt on AyahFontSize {
  double get value {
    switch (this) {
      case AyahFontSize.big:
        return 54;
      case AyahFontSize.regular:
        return 26;
    }
  }
}

class SuratPageV3 extends StatelessWidget {
  const SuratPageV3({
    Key? key,
    required this.startPage,
    this.bookmarks,
  }) : super(key: key);

  final int startPage;
  final Bookmarks? bookmarks;

  @override
  Widget build(BuildContext context) {
    return ViewModelConnector<SuratPageViewModel, SuratPageState>(
      viewModelProvider:
          StateNotifierProvider<SuratPageViewModel, SuratPageState>(
        (ref) {
          return SuratPageViewModel(
            startPage: startPage,
            bookmarks: bookmarks,
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
        if (state.pages == null || state.pages!.length < 604) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
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
              title: const Text("Surat"),
              backgroundColor: backgroundColor,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.bookmark_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This is a Bookmark')));
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
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This is a Setting')));
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPages(state: state),
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
        pageNumber: pageNumberInQuran,
      );

      allPages.add(page);
    }

    return PageView(
      controller: state.pageController,
      children: allPages,
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required pageNumber,
  }) {
    List<Widget> ayahs = <Widget>[];

    for (int i = 0; i < quranPageObject.verses.length; i++) {
      bool useDivider = i != quranPageObject.verses.length - 1;

      Widget w = _buildAyah(
        verse: quranPageObject.verses[i],
        useDivider: useDivider,
        fontSize: AyahFontSize.regular,
        page: pageNumber,
      );

      ayahs.add(w);
    }

    return SingleChildScrollView(
      key: PageStorageKey("page$pageNumber"),
      child: Column(
        children: ayahs,
      ),
    );
  }

  Widget _buildAyah({
    required Verse verse,
    required bool useDivider,
    required AyahFontSize fontSize,
    required int page,
  }) {
    List<InlineSpan> allVerses = <TextSpan>[];
    String fontFamilyPage = 'Page$page';

    for (Word word in verse.words) {
      TextSpan wordInText = TextSpan(
        text: word.code,
        style: TextStyle(
          fontFamily: fontFamilyPage,
          fontSize: fontSize.value,
          height: 1.6,
        ),
      );

      allVerses.add(wordInText);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text.rich(
              TextSpan(
                children: allVerses,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        if (useDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 10,
              color: Colors.black,
            ),
          ),
      ],
    );
  }
}
