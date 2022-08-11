import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/surat_page_settings_drawer.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/app_icons.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';


enum AyahFontSize {
  big,
  regular,
}

extension AyahFontSizeExt on AyahFontSize {
  SuratPageState get value {
    switch (this) {
      case AyahFontSize.big:
        return value.readingSettings!.valueFontSizeArabic  + 9 as SuratPageState ;
      case AyahFontSize.regular:
        return value.readingSettings!.valueFontSizeArabic as SuratPageState;
    }
  }
}


class SuratPageV3 extends StatefulWidget {
  const SuratPageV3({
    Key? key,
    required this.startPageInIndex,
    this.firstPagePointerIndex = 0,
  }) : super(key: key);

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
    VisibilityDetectorController.instance.updateInterval =
        const Duration(milliseconds: 300);

    if (widget.firstPagePointerIndex != 0) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) {
          Future.delayed(
            const Duration(milliseconds: 600),
            () {
              firstPageScrollController.scrollToIndex(
                widget.firstPagePointerIndex,
                preferPosition: AutoScrollPosition.begin,
                duration: const Duration(milliseconds: 200),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return StateNotifierConnector<SuratPageStateNotifier, SuratPageState>(
      stateNotifierProvider:
          StateNotifierProvider<SuratPageStateNotifier, SuratPageState>(
        (ref) {
          return SuratPageStateNotifier(
            startPageInIndex: widget.startPageInIndex,
            sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
          );
        },
      ),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        SuratPageState state,
        SuratPageStateNotifier notifier,
        _,
      ) {
        if (state.pages == null ||
            state.translations == null ||
            state.latins == null ||
            state.tafsirs == null ||
            state.readingSettings == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, notifier.isBookmarkChanged);
            return true;
          },
          child: Scaffold(
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
                  onPressed: () => Navigator.of(context).pop(
                    notifier.isBookmarkChanged,
                  ),
                ),
                automaticallyImplyLeading: false,
                elevation: 2.5,
                foregroundColor: Colors.black,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: notifier.visibleSuratName,
                      builder: (context, value, __) {
                        return Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    Row(
                      children: <Widget>[
                        ValueListenableBuilder(
                          valueListenable: notifier.currentPage,
                          builder: (context, value, __) {
                            return Text(
                              'Page $value',
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: notifier.visibleJuzNumber,
                          builder: (context, value, __) {
                            return Text(
                              ', Juz $value',
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                backgroundColor: backgroundColor,
                actions: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: notifier.visibleIconBookmark,
                    builder: (context, value, __) {
                      if (notifier.visibleIconBookmark.value == true) {
                        return IconButton(
                          icon: const Icon(Icons.bookmark_outlined),
                          onPressed: () {
                            notifier.deleteBookmark(notifier.currentPage.value);
                          },
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.bookmark_outline),
                          onPressed: () {
                            notifier.insertBookmark(
                              notifier.visibleSuratName.value,
                              notifier.visibleJuzNumber.value,
                              notifier.currentPage.value,
                            );
                          },
                        );
                      }
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
              child: _buildPages(
                state: state,
                notifier: notifier,
              ),
            ),
            endDrawer: SuratPageSettingsDrawer(
              isWithLatins: state.readingSettings!.isWithLatins,
              isWithTranslation: state.readingSettings!.isWithTranslations,
              isWithTafsir: state.readingSettings!.isWithTafsirs,
              fontSize: state.readingSettings!.fontSize,
              onTapLatins: (value) => notifier.setisWithLatins(value),
              onTapTranslation: (value) => notifier.setIsWithTranslations(value),
              onTapTafsir: (value) => notifier.setIsWithTafsirs(value),
              onTapAdd: (value) => notifier.addFontSize(value),
              onTapMinus: (value)=> notifier.minusFontSize(value) ,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPages({
    required SuratPageState state,
    required SuratPageStateNotifier notifier,
  }) {
    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < state.pages!.length; idx++) {
      int pageNumberInQuran = idx + 1;

      Widget page = _buildPage(
        quranPageObject: state.pages![idx],
        pageNumberInQuran: pageNumberInQuran,
        state: state,
        notifier: notifier,
      );

      allPages.add(page);
    }

    return PageView(
      reverse: true,
      controller: state.pageController,
      onPageChanged: (pageIndex) {
        int pageValue = pageIndex + 1;
        notifier.currentPage.value = pageValue;
        notifier.checkOneBookmark(pageValue);
      },
      children: allPages,
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required int pageNumberInQuran,
    required SuratPageState state,
    required SuratPageStateNotifier notifier,
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
        notifier: notifier,
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
    required SuratPageStateNotifier notifier,
  }) {
    String allVerses = '';
    String fontFamilyPage = 'Page$pageNumberInQuran';
    bool useBasmalahBeforeAyah = verse.verseNumber == 1;
    String translation =
        state.translations![verse.surahNumberInIndex][verse.verseNumberInIndex];
    String latin =
        state.latins![verse.surahNumberInIndex][verse.verseNumberInIndex];
    String tafsir =
        state.tafsirs![verse.surahNumberInIndex][verse.verseNumberInIndex];
    bool isWithTranslations = state.readingSettings!.isWithTranslations;
    bool isWithTafsirs = state.readingSettings!.isWithTafsirs;
    bool isWithLatins = state.readingSettings!.isWithLatins;
    ValueKey key = ValueKey(verse.surahNameAndAyatKey);

    for (Word word in verse.words) {
      allVerses += word.code + ' ';
    }

    return AutoScrollTag(
      key: key,
      controller: pageNumberInQuran - 1 == widget.startPageInIndex
          ? firstPageScrollController
          : AutoScrollController(),
      index: verse.hashKey,
      child: VisibilityDetector(
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 1) {
            if (notifier.visibleSuratName.value !=
                surahNumberToSurahNameMap[verse.surahNumber]!) {
              notifier.visibleSuratName.value =
                  surahNumberToSurahNameMap[verse.surahNumber]!;
              notifier.temp = verse.surahNumber;
            }

            if (notifier.visibleJuzNumber.value != verse.juzNumber) {
              notifier.visibleJuzNumber.value = verse.juzNumber;
            }
          }
        },
        key: key,
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
                    fontSize: state.readingSettings?.valueFontSizeArabic,
                    height: 1.6,
                    wordSpacing: 2,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            if (isWithLatins)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(latin, style: bodyLatin1.merge(
                    TextStyle(fontSize: state.readingSettings?.valueFontSize)
                  )),
                ),
              ),
            if (isWithTranslations)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    translation,
                    style: bodyRegular3.merge(
                       TextStyle(height: 1.5, fontSize: state.readingSettings?.valueFontSize),
                    ),
                  ),
                ),
              ),
            if (isWithTafsirs)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: backgroundTextTafsir,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tafsir,
                          style: bodyRegular3.merge(
                             TextStyle(height: 1.5 , fontSize: state.readingSettings?.valueFontSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tafsir Ringkasan Kemenag',
                          style: bodyRegular3.copyWith(
                              color: neutral900.withOpacity(0.5)),
                        ),
                      )
                    ],
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
