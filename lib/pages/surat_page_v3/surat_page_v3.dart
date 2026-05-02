import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:qurantafsir_flutter/pages/registration_and_login_page/registration_and_login_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_bookmark_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_habit_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_navigation_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/pre_tracking_animation.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/submission_dialog.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_widget.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_minimized_info.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/app_icons.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/widgets/horizontal_divider.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'widgets/widgets.dart';

enum AyahFontSize {
  big,
  regular,
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
    this.isShowBottomSheet = false,
  });

  final int startPageInIndex;
  final int firstPagePointerIndex;
  final bool isStartTracking;
  final bool isShowBottomSheet;
}

class SuratPageV3 extends ConsumerStatefulWidget {
  const SuratPageV3({
    super.key,
    required this.param,
  });

  final SuratPageV3Param param;

  @override
  ConsumerState<SuratPageV3> createState() => _SuratPageV3State();
}

class _SuratPageV3State extends ConsumerState<SuratPageV3> {
  late AutoScrollController scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    scrollController = AutoScrollController();
    VisibilityDetectorController.instance.updateInterval =
        const Duration(milliseconds: 300);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initAllNotifiers();
    });
  }

  Future<void> _initAllNotifiers() async {
    final navNotifier = ref.read(suratPageNavigationProvider.notifier);
    final contentNotifier = ref.read(suratPageContentProvider.notifier);
    final bookmarkNotifier = ref.read(suratPageBookmarkProvider.notifier);
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

    navNotifier.init(widget.param.startPageInIndex);
    habitNotifier.init(scrollController);

    await Future.wait([
      contentNotifier.load(widget.param.startPageInIndex),
      bookmarkNotifier.load(),
    ]);

    if (!mounted) return;

    navNotifier.initNavigation();

    if (widget.param.firstPagePointerIndex != 0) {
      scrollController.scrollToIndex(
        widget.param.firstPagePointerIndex,
        preferPosition: AutoScrollPosition.begin,
        duration: const Duration(milliseconds: 200),
      );
    }

    if (widget.param.isShowBottomSheet && mounted) {
      habitNotifier.playAyahAudio();
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const AudioBottomSheetWidget(),
      );
    }

    if (widget.param.isStartTracking) {
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        _startTracking(context, ref.read(suratPageHabitProvider.notifier));
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(suratPageNavigationProvider);
    final contentState = ref.watch(suratPageContentProvider);
    final bookmarkState = ref.watch(suratPageBookmarkProvider);
    final habitState = ref.watch(suratPageHabitProvider);
    final connectivityStatus = ref.watch(internetConnectionStatusProvider);

    if (navState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final navNotifier = ref.read(suratPageNavigationProvider.notifier);
    final contentNotifier = ref.read(suratPageContentProvider.notifier);
    final bookmarkNotifier = ref.read(suratPageBookmarkProvider.notifier);
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onTapBack(
          navState: navState,
          bookmarkState: bookmarkState,
          habitState: habitState,
          habitNotifier: habitNotifier,
          navNotifier: navNotifier,
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(54.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
              onPressed: () => _onTapBack(
                navState: navState,
                bookmarkState: bookmarkState,
                habitState: habitState,
                habitNotifier: habitNotifier,
                navNotifier: navNotifier,
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: 2.5,
            foregroundColor: Theme.of(context).colorScheme.primary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  navState.visibleSuratName,
                  style: QPTextStyle.getSubHeading2SemiBold(context),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Page ${navState.currentPage}',
                      style: QPTextStyle.getDescription2Regular(context),
                    ),
                    Text(
                      ', Juz ${navState.visibleJuzNumber}',
                      style: QPTextStyle.getDescription2Regular(context),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => _onPlayRecitationAppBar(
                    navState,
                    contentState,
                    habitNotifier,
                    connectivityStatus,
                  ),
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
              bookmarkState.visibleIconBookmark
                  ? IconButton(
                      icon: const Icon(Icons.bookmark_outlined),
                      onPressed: () => bookmarkNotifier.deleteBookmark(
                        navState.currentPage,
                        connectivityStatus,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.bookmark_outline),
                      onPressed: () => bookmarkNotifier.insertBookmark(
                        navState.visibleSuratName,
                        navState.currentPage,
                        connectivityStatus,
                      ),
                    ),
              IconButton(
                icon: const Icon(CustomIcons.book),
                onPressed: () => contentNotifier.setIsInFullPage(
                  !contentState.readingSettings!.isInFullPage,
                ),
              ),
              IconButton(
                icon: const Icon(CustomIcons.sliders),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildPageOnReadCTA(
            context: context,
            navState: navState,
            contentState: contentState,
            habitState: habitState,
            habitNotifier: habitNotifier,
            bookmarkNotifier: bookmarkNotifier,
            contentNotifier: contentNotifier,
            connectivityStatus: connectivityStatus,
          ),
        ),
        endDrawer: SuratPageSettingsDrawer(
          isWithLatins: contentState.readingSettings!.isWithLatins,
          isWithTranslation: contentState.readingSettings!.isWithTranslations,
          isWithTafsir: contentState.readingSettings!.isWithTafsirs,
          fontSize: contentState.readingSettings!.fontSize,
          onTapLatins: (value) => contentNotifier.setIsWithLatins(value),
          onTapTranslation: (value) =>
              contentNotifier.setIsWithTranslations(value),
          onTapTafsir: (value) => contentNotifier.setIsWithTafsirs(value),
          onTapAdd: () => contentNotifier.addFontSize(),
          onTapMinus: () => contentNotifier.minusFontSize(),
        ),
      ),
    );
  }

  Future<void> _onPlayRecitationAppBar(
    SuratPageNavigationState navState,
    SuratPageContentState contentState,
    SuratPageHabitNotifier habitNotifier,
    ConnectivityStatus connectivityStatus,
  ) async {
    if (connectivityStatus == ConnectivityStatus.isDisconnected &&
        context.mounted) {
      GeneralBottomSheet.showNoInternetBottomSheet(
        context,
        () {
          Navigator.pop(context);
          _onPlayRecitationAppBar(
              navState, contentState, habitNotifier, connectivityStatus);
        },
      );
      return;
    }

    final int pageIndex = navState.currentPage - 1;
    final List<Verse> verses = contentState.pages![pageIndex].verses;
    final Verse verse = verses.firstWhere(
      (element) => element.id == widget.param.firstPagePointerIndex,
      orElse: () => verses[0],
    );

    habitNotifier.playOnAyah(verse);
    if (mounted) {
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const AudioBottomSheetWidget(),
      );
    }
  }

  bool _onTapBack({
    required SuratPageNavigationState navState,
    required SuratPageBookmarkState bookmarkState,
    required SuratPageHabitState habitState,
    required SuratPageHabitNotifier habitNotifier,
    required SuratPageNavigationNotifier navNotifier,
  }) {
    if (!habitState.isRecording) {
      final param = SuratPageV3OnPopParam(
        isBookmarkChanged: bookmarkState.isBookmarkChanged,
        isFavoriteAyahChanged: bookmarkState.isFavoriteAyahChanged,
        isHabitDailySummaryChanged: habitState.isHabitDailySummaryChanged,
      );
      Navigator.pop(context, param);
      return true;
    }

    _buildTrackerSubmissionDialog(habitNotifier, isFromTapBack: true);
    return true;
  }

  Widget _buildPageOnReadCTA({
    required BuildContext context,
    required SuratPageNavigationState navState,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
    required SuratPageHabitNotifier habitNotifier,
    required SuratPageBookmarkNotifier bookmarkNotifier,
    required SuratPageContentNotifier contentNotifier,
    required ConnectivityStatus connectivityStatus,
  }) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final navNotifier = ref.read(suratPageNavigationProvider.notifier);

    final Widget pages = contentState.readingSettings!.isInFullPage
        ? _buildPagesInFullPage(
            navState: navState,
            contentState: contentState,
            habitState: habitState,
            navNotifier: navNotifier,
            habitNotifier: habitNotifier,
            bookmarkNotifier: bookmarkNotifier,
            context: context,
            orientation: orientation,
          )
        : _buildPages(
            navState: navState,
            contentState: contentState,
            habitState: habitState,
            navNotifier: navNotifier,
            habitNotifier: habitNotifier,
            bookmarkNotifier: bookmarkNotifier,
            orientation: orientation,
          );

    final double bottomPadding = MediaQuery.of(context).size.height * 0.025;

    return Stack(
      children: [
        pages,
        if (habitState.isRecording)
          Positioned(
            child: _buildPageTracker(habitNotifier, habitState),
          ),
        if (habitState.isOnReadCTAVisible)
          Positioned(
            bottom: bottomPadding,
            width: MediaQuery.of(context).size.width - 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(builder: (context) {
                        final surahNumber =
                            surahNameToSurahNumberMap[navState.visibleSuratName]
                                ?? 0;
                        if (contentState
                                .availableAyahTadabburs[surahNumber] !=
                            null) {
                          return ButtonBrandSoft(
                            leftWidget: const Icon(
                              Icons.menu_book,
                              size: 12,
                              color: QPColors.brandFair,
                            ),
                            title: 'Tadabbur ${navState.visibleSuratName}',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutePaths.routeReadTadabbur,
                                arguments: ReadTadabburParam(
                                  surahName: navState.visibleSuratName,
                                  surahId: surahNumber,
                                  isFromSurahPage: true,
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      if (!habitState.isRecording)
                        ButtonPrimary(
                          label: 'Start Tracking',
                          size: ButtonSize.small,
                          onTap: () async {
                            if (!habitNotifier.isLoggedIn) {
                              final dynamic res = await Navigator.pushNamed(
                                context,
                                RoutePaths.routeLogin,
                                arguments: RegistrationAndLoginPageParam(
                                  shouldNavigateTabToHome: false,
                                ),
                              );

                              if (res is bool && res) {
                                setState(() {});
                                await _initAllNotifiers();
                                Future.delayed(Duration.zero, () {
                                  if (!context.mounted) return;
                                  _startTracking(
                                    context,
                                    ref.read(
                                        suratPageHabitProvider.notifier),
                                  );
                                });
                              }
                              return;
                            }

                            _startTracking(context, habitNotifier);
                          },
                        ),
                    ],
                  ),
                  if (habitState.showMinimizedAudioPlayer) ...<Widget>[
                    const SizedBox(height: 20),
                    AudioMinimizedInfo(
                      onTapContainer: () {
                        GeneralBottomSheet.showBaseBottomSheet(
                          context: context,
                          widgetChild: const AudioBottomSheetWidget(),
                        );
                      },
                      onClose: () => habitNotifier.stopRecitation(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _startTracking(
    BuildContext context,
    SuratPageHabitNotifier notifier,
  ) async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: PreHabitTrackingAnimation(notifier: notifier),
      ),
    );
  }

  Widget _buildPageInFullPage({
    required SuratPageNavigationState navState,
    required SuratPageContentState contentState,
    required int pageIndex,
    required BuildContext context,
    required SuratPageNavigationNotifier navNotifier,
    required Orientation orientation,
  }) {
    final List<String> texts = List<String>.filled(15, '');
    final int page = pageIndex + 1;

    for (final Verse verse in contentState.pages![pageIndex].verses) {
      for (final Word word in verse.words) {
        texts[word.lineNumber - 1] += word.code;
      }
    }

    while (navNotifier.separatorBuilderIndex <
            contentState.fullPageSeparators!.length &&
        contentState.fullPageSeparators![navNotifier.separatorBuilderIndex]
                .page ==
            page) {
      final FullPageSeparator separator =
          contentState.fullPageSeparators![navNotifier.separatorBuilderIndex];
      if (!separator.bismillah) {
        texts[separator.line - 1] = separator.unicode!;
      }
      navNotifier.separatorBuilderIndex++;
    }

    List<Widget> textInWidgets = texts
        .map(
          (String words) => _buildFullPagePerLine(
            page: page,
            text: words,
            contentState: contentState,
            orientation: orientation,
          ),
        )
        .toList();

    final double bottomPadding = MediaQuery.of(context).size.height * 0.1;
    final double topPadding = MediaQuery.of(context).size.height * 0.05;

    if (orientation == Orientation.landscape) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: textInWidgets,
        ),
      );
    }

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
    SuratPageHabitNotifier habitNotifier,
    SuratPageHabitState habitState,
  ) {
    return GestureDetector(
      onTap: () => _buildTrackerSubmissionDialog(habitNotifier),
      child: Container(
        height: 24,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(1.0, 2.0),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stop_circle_outlined, size: 14.0, color: red300),
            const SizedBox(width: 9),
            Text(
              'Stop Tracking (${habitState.recordedPagesAsRead}/${habitNotifier.habitDailyTarget} Page)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPagePerLine({
    required String text,
    required int page,
    required SuratPageContentState contentState,
    required Orientation orientation,
  }) {
    String fontFamily = 'Page$page';
    if (text.length == 1) {
      fontFamily = 'SurahName';
    }

    if (text.isEmpty) {
      if (page == 1 || page == 2) {
        return const SizedBox.shrink();
      }
      return _buildBasmalah(orientation: orientation, isInFullPage: true);
    }

    if (page == 1 || page == 2) {
      if (orientation == Orientation.landscape) {
        return AutoSizeText(
          text,
          style: TextStyle(
            height: 1.5,
            fontFamily: fontFamily,
            color: Theme.of(context).colorScheme.primary,
          ),
          maxLines: 1,
          maxFontSize: double.infinity,
          minFontSize: 56,
        );
      }
      return AutoSizeText(
        text,
        style: TextStyle(
          height: 1.5,
          fontFamily: fontFamily,
          fontSize: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (orientation == Orientation.landscape) {
      return SingleChildScrollView(
        child: Center(
          child: AutoSizeText(
            text,
            style: TextStyle(
              height: 1.5,
              fontFamily: fontFamily,
              color: Theme.of(context).colorScheme.primary,
            ),
            maxLines: 1,
            maxFontSize: double.infinity,
            minFontSize: 50,
          ),
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
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPagesInFullPage({
    required SuratPageNavigationState navState,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
    required SuratPageNavigationNotifier navNotifier,
    required SuratPageHabitNotifier habitNotifier,
    required SuratPageBookmarkNotifier bookmarkNotifier,
    required BuildContext context,
    required Orientation orientation,
  }) {
    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < contentState.pages!.length; idx++) {
      allPages.add(_buildPageInFullPage(
        navState: navState,
        contentState: contentState,
        pageIndex: idx,
        context: context,
        navNotifier: navNotifier,
        orientation: orientation,
      ));
    }

    navNotifier.resetSeparatorBuilderIndex();

    return GestureDetector(
      onTap: () {
        final habitN = ref.read(suratPageHabitProvider.notifier);
        habitN.setShowMinimizedAudioPlayer(
          !ref.read(suratPageHabitProvider).isOnReadCTAVisible,
        );
      },
      child: PageView(
        reverse: true,
        controller: navState.pageController,
        onPageChanged: (pageIndex) {
          navNotifier.updateOnPageChanged(pageIndex, contentState.pages!);
          bookmarkNotifier
              .checkIsBookmarkExists(navState.currentPage);
          habitNotifier.changePageOnRecording(navState.currentPage);
          final habitN = ref.read(suratPageHabitProvider.notifier);
          habitN.setShowMinimizedAudioPlayer(
            ref.read(suratPageHabitProvider).isOnReadCTAVisible,
          );
        },
        children: allPages,
      ),
    );
  }

  Widget _buildPages({
    required SuratPageNavigationState navState,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
    required SuratPageNavigationNotifier navNotifier,
    required SuratPageHabitNotifier habitNotifier,
    required SuratPageBookmarkNotifier bookmarkNotifier,
    required Orientation orientation,
  }) {
    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < contentState.pages!.length; idx++) {
      allPages.add(_buildPage(
        quranPageObject: contentState.pages![idx],
        pageNumberInQuran: idx + 1,
        navState: navState,
        contentState: contentState,
        habitState: habitState,
        navNotifier: navNotifier,
        habitNotifier: habitNotifier,
        bookmarkNotifier: bookmarkNotifier,
        orientation: orientation,
      ));
    }

    return PageView(
      reverse: true,
      controller: navState.pageController,
      onPageChanged: (pageIndex) {
        final int pageValue = pageIndex + 1;
        habitNotifier.changePageOnRecording(pageValue);
        bookmarkNotifier.checkIsBookmarkExists(pageValue);
        navNotifier.updateCurrentPage(pageValue);
        navNotifier.updateVisibleJuz(
            contentState.pages![pageIndex].verses[0].juzNumber);
      },
      children: allPages,
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required int pageNumberInQuran,
    required SuratPageNavigationState navState,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
    required SuratPageNavigationNotifier navNotifier,
    required SuratPageHabitNotifier habitNotifier,
    required SuratPageBookmarkNotifier bookmarkNotifier,
    required Orientation orientation,
  }) {
    List<Widget> ayahs = <Widget>[];
    for (int i = 0; i < quranPageObject.verses.length; i++) {
      bool useDivider = i != quranPageObject.verses.length - 1;
      Verse verse = quranPageObject.verses[i];

      ayahs.add(_buildAyah(
        verse: verse,
        useDivider: useDivider,
        fontSize: pageNumberInQuran == 1 || pageNumberInQuran == 2
            ? orientation == Orientation.landscape
                ? contentState
                    .readingSettings!.valueFontSizeArabicFirstSheetLandscape
                : contentState.readingSettings!.valueFontSizeArabicFirstSheet
            : orientation == Orientation.landscape
                ? contentState.readingSettings!.valueFontSizeArabicLandscape
                : contentState.readingSettings!.valueFontSizeArabic,
        pageNumberInQuran: pageNumberInQuran,
        navState: navState,
        contentState: contentState,
        habitState: habitState,
        navNotifier: navNotifier,
        habitNotifier: habitNotifier,
        bookmarkNotifier: bookmarkNotifier,
        orientation: orientation,
      ));
    }

    return ListView(
      padding:
          habitState.isRecording ? const EdgeInsets.only(top: 20) : EdgeInsets.zero,
      controller: scrollController,
      key: PageStorageKey('page$pageNumberInQuran'),
      children: ayahs,
    );
  }

  Widget _buildAyah({
    required Verse verse,
    required bool useDivider,
    required double fontSize,
    required int pageNumberInQuran,
    required SuratPageNavigationState navState,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
    required SuratPageNavigationNotifier navNotifier,
    required SuratPageHabitNotifier habitNotifier,
    required SuratPageBookmarkNotifier bookmarkNotifier,
    required Orientation orientation,
  }) {
    String allVerses = '';
    String fontFamilyPage = 'Page$pageNumberInQuran';

    bool useBasmalahBeforeAyah =
        navState.visibleSuratName != "At-Taubah" && verse.verseNumber == 1;

    String? translation =
        contentState.translations?[verse.surahNumberInIndex][verse.verseNumberInIndex];
    String? latin =
        contentState.latins?[verse.surahNumberInIndex][verse.verseNumberInIndex];
    String? tafsir =
        contentState.tafsirs?[verse.surahNumberInIndex][verse.verseNumberInIndex];
    bool isWithTranslations = contentState.readingSettings!.isWithTranslations;
    bool isWithTafsirs = contentState.readingSettings!.isWithTafsirs;
    bool isWithLatins = contentState.readingSettings!.isWithLatins;
    bool isFavorited = bookmarkNotifier.isAyahFavorited(verse.id);
    ValueKey key = ValueKey(verse.surahNameAndAyatKey);

    for (Word word in verse.words) {
      allVerses += '${word.code} ';
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
            navNotifier.updateVisibleSurah(verse.surahNumber);
            navNotifier.updateVisibleJuz(verse.juzNumber);
          }
        },
        key: key,
        child: Column(
          children: <Widget>[
            if (useBasmalahBeforeAyah) _buildBasmalah(orientation: orientation),
            GestureDetector(
              onLongPress: () {
                GeneralBottomSheet().showGeneralBottomSheet(
                  context,
                  verse.surahNameAndAyatKey,
                  FavoriteAyahCTA(
                    onTap: () async {
                      await bookmarkNotifier.toggleFavoriteAyah(
                        surahNumber: verse.surahNumber,
                        ayahNumber: verse.verseNumber,
                        ayahID: verse.id,
                        page: pageNumberInQuran,
                      );
                    },
                    isFavorited: bookmarkNotifier.isAyahFavorited(verse.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (isFavorited)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage(StoredIcon.iconFavorite.path),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.blackFair,
                              light: QPColors.blackFair,
                              brown: QPColors.brownModeHeavy,
                              context: context,
                            ),
                            padding: const EdgeInsets.all(0),
                            alignment: Alignment.centerLeft,
                            icon: const Icon(Icons.play_circle_outline),
                            iconSize: 20,
                            onPressed: () =>
                                _playOnAyah(habitNotifier, verse, connectivityStatus: ref.read(internetConnectionStatusProvider)),
                          ),
                          Expanded(
                            child: Text(
                              allVerses,
                              style: TextStyle(
                                fontFamily: fontFamilyPage,
                                fontSize: fontSize,
                                height: 1.6,
                                wordSpacing: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isWithLatins)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    latin!,
                    style:
                        QPTextStyle.getDescription1Regular(context).copyWith(
                      fontSize: orientation == Orientation.landscape
                          ? contentState.readingSettings!.valueFontSizeLandscape
                          : contentState.readingSettings?.valueFontSize,
                      color: QPColors.getColorBasedTheme(
                        dark: QPColors.blackSoft,
                        light: QPColors.neutral600,
                        brown: QPColors.brownModeMassive,
                        context: context,
                      ),
                    ),
                  ),
                ),
              ),
            if (isWithTranslations)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    translation!,
                    style:
                        QPTextStyle.getDescription1Regular(context).copyWith(
                      height: 1.5,
                      fontSize: contentState.readingSettings?.valueFontSize,
                    ),
                  ),
                ),
              ),
            if (isWithTafsirs)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.darkModeFair,
                    light: QPColors.whiteSoft,
                    brown: QPColors.brownModeHeavy,
                    context: context,
                  ),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(8)),
                ),
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
                          tafsir!,
                          style: QPTextStyle.getDescription1Regular(context)
                              .copyWith(
                            height: 1.5,
                            fontSize:
                                contentState.readingSettings?.valueFontSize,
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.whiteFair,
                              light: QPColors.blackFair,
                              brown: QPColors.brownModeMassive,
                              context: context,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tafsir Ringkasan Kemenag',
                          style: QPTextStyle.getDescription1Regular(context)
                              .copyWith(
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.blackSoft,
                              light: Colors.black.withValues(alpha: 0.5),
                              brown: QPColors.brownModeMassive,
                              context: context,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (contentState.availableAyahTadabburs[verse.surahNumber] != null &&
                contentState.availableAyahTadabburs[verse.surahNumber]!
                    .contains(verse.verseNumber))
              Align(
                alignment: Alignment.centerRight,
                child: _buildIsTadabburAvailableFlag(),
              ),
            if (useDivider)
              const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: HorizontalDivider(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _playOnAyah(
    SuratPageHabitNotifier habitNotifier,
    Verse verse, {
    required ConnectivityStatus connectivityStatus,
  }) async {
    if (connectivityStatus == ConnectivityStatus.isDisconnected &&
        context.mounted) {
      GeneralBottomSheet.showNoInternetBottomSheet(
        context,
        () {
          Navigator.pop(context);
          _playOnAyah(habitNotifier, verse,
              connectivityStatus: connectivityStatus);
        },
      );
      return;
    }

    habitNotifier.playOnAyah(verse);
    if (mounted) {
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const AudioBottomSheetWidget(),
      );
    }
  }

  Widget _buildIsTadabburAvailableFlag() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book, size: 14),
          const SizedBox(width: 4),
          Text(
            'Tadabbur Available',
            style: QPTextStyle.getButton3Medium(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.brandFair,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasmalah({
    bool isInFullPage = false,
    required Orientation orientation,
  }) {
    if (isInFullPage) {
      return Image.asset(
        'images/bismillah_v2.png',
        width: orientation == Orientation.landscape ? 300 : 170,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return Image.asset(
      'images/bismillah_v2.png',
      color: Theme.of(context).colorScheme.primary,
      width: 165,
      height: 80,
      fit: BoxFit.contain,
    );
  }

  Future<void> _buildTrackerSubmissionDialog(
    SuratPageHabitNotifier habitNotifier, {
    bool isFromTapBack = false,
  }) async {
    showQPGeneralDialog<bool>(
      context: context,
      builder: (context) {
        return TrackingSubmissionDialog(
          habitNotifier: habitNotifier,
          isFromTapBack: isFromTapBack,
        );
      },
    );
  }
}
