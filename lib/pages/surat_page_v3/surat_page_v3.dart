import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/post_tracking_dialog.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/pre_tracking_animation.dart';
import 'package:qurantafsir_flutter/shared/constants/Icon.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/app_icons.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'widgets/widgets.dart';

enum AyahFontSize {
  big,
  regular,
}

//! Apakah sabi untuk dihapus extension ini?
extension AyahFontSizeExt on AyahFontSize {
  SuratPageState get value {
    switch (this) {
      case AyahFontSize.big:
        return value.readingSettings!.valueFontSizeArabic + 9 as SuratPageState;
      case AyahFontSize.regular:
        return value.readingSettings!.valueFontSizeArabic as SuratPageState;
    }
  }
}

class SuratPageV3OnPopParam {
  SuratPageV3OnPopParam({
    this.isBookmarkChanged = false,
    this.isFavoriteAyahChanged = false,
    this.isHabitDailySummaryChanged = false,
  });

  final bool isBookmarkChanged;
  final bool isFavoriteAyahChanged;
  final bool isHabitDailySummaryChanged;
}

class SuratPageV3Param {
  SuratPageV3Param({
    required this.startPageInIndex,
    this.firstPagePointerIndex = 0,
    this.isStartTracking = false,
  });

  final int startPageInIndex;
  final int firstPagePointerIndex;
  final bool isStartTracking;
}

class SuratPageV3 extends StatefulWidget {
  const SuratPageV3({
    Key? key,
    required this.param,
  }) : super(key: key);

  final SuratPageV3Param param;

  @override
  State<StatefulWidget> createState() {
    return _SuratPageV3State();
  }
}

class _SuratPageV3State extends State<SuratPageV3> {
  late AutoScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = AutoScrollController();
    VisibilityDetectorController.instance.updateInterval =
        const Duration(milliseconds: 300);

    if (widget.param.firstPagePointerIndex != 0) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) {
          Future.delayed(
            const Duration(milliseconds: 600),
            () {
              scrollController.scrollToIndex(
                widget.param.firstPagePointerIndex,
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
            startPageInIndex: widget.param.startPageInIndex,
            sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
            bookmarkApi: ref.watch(bookmarkApiProvider),
            bookmarksService: ref.watch(bookmarksService),
            authenticationService: ref.watch(authenticationService),
            scrollController: scrollController,
            isLoggedIn: ref.watch(authenticationService).isLoggedIn,
          );
        },
      ),
      onStateNotifierReady: (notifier) async {
        if (widget.param.isStartTracking) {
          Future.delayed(Duration.zero, () {
            _startTracking(context, notifier);
          });
        }

        final ConnectivityResult connectivityResult =
            await Connectivity().checkConnectivity();
        await notifier.initStateNotifier(
          connectivityResult: connectivityResult,
        );
      },
      builder: (
        BuildContext context,
        SuratPageState state,
        SuratPageStateNotifier notifier,
        _,
      ) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return WillPopScope(
          onWillPop: () async => _onTapBack(
            notifier: notifier,
            state: state,
          ),
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
                  onPressed: () async => _onTapBack(
                    notifier: notifier,
                    state: state,
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
                          onPressed: () async {
                            final ConnectivityResult connectivityResult =
                                await Connectivity().checkConnectivity();
                            notifier.deleteBookmark(
                              notifier.currentPage.value,
                              connectivityResult,
                            );
                          },
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.bookmark_outline),
                          onPressed: () async {
                            final ConnectivityResult connectivityResult =
                                await Connectivity().checkConnectivity();
                            notifier.insertBookmark(
                              notifier.visibleSuratName.value,
                              notifier.currentPage.value,
                              connectivityResult,
                            );
                          },
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(CustomIcons.book),
                    onPressed: () => notifier
                        .setIsInFullPage(!state.readingSettings!.isInFullPage),
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
              child: _buildPageWithTracker(
                context: context,
                sn: notifier,
                state: state,
              ),
            ),
            endDrawer: SuratPageSettingsDrawer(
              isWithLatins: state.readingSettings!.isWithLatins,
              isWithTranslation: state.readingSettings!.isWithTranslations,
              isWithTafsir: state.readingSettings!.isWithTafsirs,
              fontSize: state.readingSettings!.fontSize,
              onTapLatins: (value) => notifier.setisWithLatins(value),
              onTapTranslation: (value) =>
                  notifier.setIsWithTranslations(value),
              onTapTafsir: (value) => notifier.setIsWithTafsirs(value),
              onTapAdd: (value) => notifier.addFontSize(value),
              onTapMinus: (value) => notifier.minusFontSize(value),
            ),
          ),
        );
      },
    );
  }

  bool _onTapBack({
    required SuratPageStateNotifier notifier,
    required SuratPageState state,
  }) {
    if (!state.isRecording) {
      final SuratPageV3OnPopParam param = SuratPageV3OnPopParam(
        isBookmarkChanged: notifier.isBookmarkChanged,
        isFavoriteAyahChanged: notifier.isFavoriteAyahChanged,
        isHabitDailySummaryChanged: notifier.isHabitDailySummaryChanged,
      );
      Navigator.pop(context, param);
      return true;
    }

    _buildTrackerSubmissionDialog(
      notifier,
      isFromTapBack: true,
    );

    return true;
  }

  Widget _buildPageWithTracker({
    required SuratPageState state,
    required SuratPageStateNotifier sn,
    required BuildContext context,
  }) {
    final Widget pages = state.readingSettings!.isInFullPage
        ? _buildPagesInFullPage(
            state: state,
            notifier: sn,
            context: context,
          )
        : _buildPages(
            state: state,
            notifier: sn,
          );

    final double bottomPadding = MediaQuery.of(context).size.height * 0.025;

    return Stack(
      children: [
        pages,
        ValueListenableBuilder(
          valueListenable: sn.isTrackerVisible,
          builder: (_, bool value, __) {
            if (state.isRecording && value) {
              return Positioned(
                child: _buildPageTracker(sn),
              );
            }

            if (!state.isRecording && value) {
              return Positioned(
                bottom: bottomPadding,
                right: 24,
                child: ButtonPrimary(
                  label: 'Start Tracking',
                  size: ButtonSize.small,
                  onTap: () {
                    if (!sn.isLoggedIn) {
                      sn.forceLoginToEnableHabit(
                        context,
                        RoutePaths.routeSurahPage,
                        <String, dynamic>{
                          'startPageInIndex': sn.currentPage.value,
                          'isStartTracking': true,
                        },
                      );
                      return;
                    }

                    _startTracking(context, sn);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Future<void> _startTracking(
    BuildContext context,
    SuratPageStateNotifier notifier,
  ) async {
    const Duration _duration = Duration(milliseconds: 6000);
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: const PreHabitTrackingAnimation(),
      ),
    );
    Timer(_duration, () {
      Navigator.pop(context);
      notifier.startRecording();
    });
  }

  Widget _buildPageInFullPage({
    required SuratPageState state,
    required int pageIndex,
    required BuildContext context,
    required SuratPageStateNotifier notifier,
  }) {
    final List<String> texts = List<String>.filled(15, '');
    final int page = pageIndex + 1;

    for (final Verse verse in state.pages![pageIndex].verses) {
      for (final Word word in verse.words) {
        texts[word.lineNumber - 1] += word.code;
      }
    }

    while (state.separatorBuilderIndex < state.fullPageSeparators!.length &&
        state.fullPageSeparators![state.separatorBuilderIndex].page == page) {
      final FullPageSeparator separator =
          state.fullPageSeparators![state.separatorBuilderIndex];

      if (!separator.bismillah) {
        texts[separator.line - 1] = separator.unicode!;
      }

      state.separatorBuilderIndex++;
    }

    List<Widget> textInWidgets = texts
        .map(
          (String words) => _buildFullPagePerLine(
            page: page,
            text: words,
          ),
        )
        .toList();

    final double bottomPadding = MediaQuery.of(context).size.height * 0.1;
    final double topPadding = MediaQuery.of(context).size.height * 0.05;

    return Padding(
      padding: EdgeInsets.fromLTRB(11, topPadding, 11, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: textInWidgets,
      ),
    );
  }

  Widget _buildPageTracker(
    SuratPageStateNotifier sn,
  ) {
    return GestureDetector(
      onTap: () => _buildTrackerSubmissionDialog(sn),
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(1.0, 2.0),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            )
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.stop_circle_outlined,
              size: 14.0,
              color: red300,
            ),
            const SizedBox(
              width: 9,
            ),
            ValueListenableBuilder(
              valueListenable: sn.recordedPagesAsRead,
              builder: (context, value, __) {
                return Text(
                  'Stop Tracking ($value/${sn.habitDailyTarget} Page)',
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPagePerLine({
    required String text,
    required int page,
  }) {
    String fontFamily = 'Page$page';
    if (text.length == 1) {
      fontFamily = 'SurahName';
    }

    if (text.isEmpty) {
      if (page == 1 || page == 2) {
        return const SizedBox.shrink();
      }

      return _buildBasmalah(
        isInFullPage: true,
      );
    }

    if (page == 1 || page == 2) {
      return AutoSizeText(
        text,
        style: TextStyle(
          height: 1.5,
          fontFamily: fontFamily,
          fontSize: 30,
        ),
      );
    }

    return Expanded(
      child: AutoSizeText(
        text,
        style: TextStyle(
          height: 1.5,
          fontFamily: fontFamily,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _buildPagesInFullPage({
    required SuratPageState state,
    required SuratPageStateNotifier notifier,
    required BuildContext context,
  }) {
    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < state.pages!.length; idx++) {
      Widget page = _buildPageInFullPage(
        state: state,
        pageIndex: idx,
        context: context,
        notifier: notifier,
      );

      allPages.add(page);
    }

    return PageView(
      reverse: true,
      controller: state.pageController,
      onPageChanged: (pageIndex) {
        int pageValue = pageIndex + 1;
        int initPage = widget.param.startPageInIndex + 1;
        int surahNumber = state.pages![pageIndex].verses[0].surahNumber;
        String surahName = surahNumberToSurahNameMap[surahNumber] ?? '';
        notifier.visibleSuratName.value = surahName;
        notifier.currentPage.value = pageValue;
        notifier.checkIsBookmarkExists(pageValue);
        notifier.changePageOnRecording(pageValue, initPage);
        notifier.isTrackerVisible.value = true;
      },
      children: allPages,
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
        int initPage = widget.param.startPageInIndex + 1;
        int pageValue = pageIndex + 1;
        notifier.currentPage.value = pageValue;
        notifier.checkIsBookmarkExists(pageValue);
        notifier.changePageOnRecording(pageValue, initPage);
        notifier.isTrackerVisible.value = true;
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
    List<Widget> ayahs = <Widget>[];
    for (int i = 0; i < quranPageObject.verses.length; i++) {
      bool useDivider = i != quranPageObject.verses.length - 1;
      Verse verse = quranPageObject.verses[i];

      Widget w = _buildAyah(
        verse: verse,
        useDivider: useDivider,
        fontSize: pageNumberInQuran == 1 || pageNumberInQuran == 2
            ? state.readingSettings!.valueFontSizeArabicFirstSheet
            : state.readingSettings!.valueFontSizeArabic,
        pageNumberInQuran: pageNumberInQuran,
        state: state,
        notifier: notifier,
      );

      ayahs.add(w);
    }

    return Padding(
      padding:
          state.isRecording ? const EdgeInsets.only(top: 20) : EdgeInsets.zero,
      child: SingleChildScrollView(
        controller: scrollController,
        key: PageStorageKey('page$pageNumberInQuran'),
        child: Column(
          children: ayahs,
        ),
      ),
    );
  }

  Widget _buildAyah({
    required Verse verse,
    required bool useDivider,
    required double fontSize,
    required int pageNumberInQuran,
    required SuratPageState state,
    required SuratPageStateNotifier notifier,
  }) {
    String allVerses = '';
    String fontFamilyPage = 'Page$pageNumberInQuran';

    bool useBasmalahBeforeAyah =
        notifier.visibleSuratName.value != "At-Taubah" &&
            verse.verseNumber == 1;

    String translation =
        state.translations![verse.surahNumberInIndex][verse.verseNumberInIndex];
    String latin =
        state.latins![verse.surahNumberInIndex][verse.verseNumberInIndex];
    String tafsir =
        state.tafsirs![verse.surahNumberInIndex][verse.verseNumberInIndex];
    bool isWithTranslations = state.readingSettings!.isWithTranslations;
    bool isWithTafsirs = state.readingSettings!.isWithTafsirs;
    bool isWithLatins = state.readingSettings!.isWithLatins;
    bool isFavorited = notifier.isAyahFavorited(verse.id);
    ValueKey key = ValueKey(verse.surahNameAndAyatKey);

    for (Word word in verse.words) {
      allVerses += word.code + ' ';
    }

    return AutoScrollTag(
      key: key,
      controller: pageNumberInQuran - 1 == widget.param.startPageInIndex
          ? scrollController
          : AutoScrollController(),
      index: verse.id,
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
            GestureDetector(
              onLongPress: () {
                GeneralBottomSheet().showGeneralBottomSheet(
                  context,
                  verse.surahNameAndAyatKey,
                  FavoriteAyahCTA(
                    onTap: () async {
                      final ConnectivityResult connectivityResult =
                          await Connectivity().checkConnectivity();

                      await notifier.toggleFavoriteAyah(
                        surahNumber: verse.surahNumber,
                        ayahNumber: verse.verseNumber,
                        ayahID: verse.id,
                        page: pageNumberInQuran,
                        connectivityResult: connectivityResult,
                      );
                    },
                    isFavorited: notifier.isAyahFavorited(
                      verse.id,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (isFavorited)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                IconPath.iconFavorite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        allVerses,
                        style: TextStyle(
                          fontFamily: fontFamilyPage,
                          fontSize: fontSize,
                          height: 1.6,
                          wordSpacing: 2,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isWithLatins)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(latin,
                      style: bodyLatin1.merge(TextStyle(
                          fontSize: state.readingSettings?.valueFontSize))),
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
                      TextStyle(
                          height: 1.5,
                          fontSize: state.readingSettings?.valueFontSize),
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
                            TextStyle(
                                height: 1.5,
                                fontSize: state.readingSettings?.valueFontSize),
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

  Widget _buildBasmalah({
    bool isInFullPage = false,
  }) {
    if (isInFullPage) {
      return Image.asset(
        'images/bismillah_v2.png',
        width: 170,
      );
    }

    return Container(
      width: 165,
      height: 80,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'images/bismillah_v2.png',
          ),
        ),
      ),
    );
  }

  Future<void> _buildTrackerSubmissionDialog(
    SuratPageStateNotifier notifier, {
    bool isFromTapBack = false,
  }) async {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                isFromTapBack
                    ? 'Please submit your reading progress before back to the Homepage'
                    : "You've finished reading....",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: neutral900,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  _buildTrackerSubmissionDialogInput(notifier),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'Pages',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: neutral600,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              ButtonSecondary(
                label: 'Submit',
                onTap: () async {
                  final bool isComplete = await notifier.stopRecording();
                  Navigator.pop(context);

                  if (isFromTapBack) {
                    HabitProgressPostTrackingDialog.onTapBackTrackingDialog(
                      context: context,
                      sharedPreferenceService: notifier.sharedPreferenceService,
                      isComplete: isComplete,
                    );
                    return true;
                  }

                  HabitProgressPostTrackingDialog.onSubmitPostTrackingDialog(
                    context: context,
                    sharedPreferenceService: notifier.sharedPreferenceService,
                    isComplete: isComplete,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackerSubmissionDialogInput(SuratPageStateNotifier notifier) {
    notifier.habitTrackerSubmissionController.value = TextEditingValue(
      text: notifier.recordedPagesList.length.toString(),
    );

    return SizedBox(
      width: 60,
      child: TextField(
        controller: notifier.habitTrackerSubmissionController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: neutral600,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.all(7),
          hintText: '1',
          hintStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: neutral400,
          ),
          border: enabledInputBorder,
          enabledBorder: enabledInputBorder,
          errorBorder: errorInputBorder,
          focusedErrorBorder: errorInputBorder,
        ),
      ),
    );
  }
}
