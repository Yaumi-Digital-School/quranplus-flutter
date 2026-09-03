import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/registration_and_login_page/registration_and_login_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/pre_tracking_animation.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/submission_dialog.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_widget.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'widgets/widgets.dart';

enum AyahFontSize { big, regular }

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
  const SuratPageV3({super.key, required this.param});

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
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 300,
    );
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
    final bool isLoading = ref.watch(
      suratPageNavigationProvider.select((s) => s.isLoading),
    );

    // Keep these auto-dispose providers alive during async initialization
    // without rebuilding the whole page when they emit. We return early during
    // loading and the child ConsumerWidgets do their own narrow watching, so a
    // no-op listen is enough to hold them (a plain watch would rebuild the whole
    // tree on every emission).
    ref.listen(suratPageContentProvider, (_, __) {});
    ref.listen(suratPageBookmarkProvider, (_, __) {});
    ref.listen(suratPageHabitProvider, (_, __) {});

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onTapBack(habitNotifier);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: SuratPageAppBar(
          onTapBack: () => _onTapBack(habitNotifier),
          onTapPlayRecitation: () => _onPlayRecitationAppBar(),
          onTapOpenSettings: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBody(context),
        ),
        endDrawer: const SuratPageSettingsDrawer(),
      ),
    );
  }

  void _onPlayRecitationAppBar() {
    final connectivityStatus = ref.read(internetConnectionStatusProvider);
    final navState = ref.read(suratPageNavigationProvider);
    final contentState = ref.read(suratPageContentProvider);
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

    if (connectivityStatus == ConnectivityStatus.isDisconnected &&
        context.mounted) {
      GeneralBottomSheet.showNoInternetBottomSheet(context, () {
        Navigator.pop(context);
        _onPlayRecitationAppBar();
      });
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

  void _onTapBack(SuratPageHabitNotifier habitNotifier) {
    final habitState = ref.read(suratPageHabitProvider);
    final bookmarkState = ref.read(suratPageBookmarkProvider);

    if (!habitState.isRecording) {
      final param = SuratPageV3OnPopParam(
        isBookmarkChanged: bookmarkState.isBookmarkChanged,
        isFavoriteAyahChanged: bookmarkState.isFavoriteAyahChanged,
        isHabitDailySummaryChanged: habitState.isHabitDailySummaryChanged,
      );
      Navigator.pop(context, param);
      return;
    }

    _buildTrackerSubmissionDialog(habitNotifier, isFromTapBack: true);
  }

  Widget _buildBody(BuildContext context) {
    final bool isInFullPage = ref.watch(
      suratPageContentProvider.select((s) => s.readingSettings!.isInFullPage),
    );
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);
    final navNotifier = ref.read(suratPageNavigationProvider.notifier);
    final bookmarkNotifier = ref.read(suratPageBookmarkProvider.notifier);
    final Orientation orientation = MediaQuery.of(context).orientation;

    final Widget pages = isInFullPage
        ? FullPagePagesView(
            orientation: orientation,
            scrollController: scrollController,
            onTapToggleCTA: () {
              habitNotifier.toggleReadCTAVisible();
            },
            onPageChanged: (pageIndex) {
              final pages = ref.read(suratPageContentProvider).pages!;
              navNotifier.updateOnPageChanged(pageIndex, pages);
              bookmarkNotifier.checkIsBookmarkExists(pageIndex + 1);
              habitNotifier.changePageOnRecording(pageIndex + 1);
              habitNotifier.setIsOnReadCTAVisible(true);
            },
          )
        : PerAyahPagesView(
            orientation: orientation,
            scrollController: scrollController,
            startPageInIndex: widget.param.startPageInIndex,
            onPageChanged: (pageIndex) {
              final pages = ref.read(suratPageContentProvider).pages!;
              final int pageValue = pageIndex + 1;
              habitNotifier.changePageOnRecording(pageValue);
              bookmarkNotifier.checkIsBookmarkExists(pageValue);
              navNotifier.updateCurrentPage(pageValue);
              navNotifier.updateVisibleJuz(
                pages[pageIndex].verses[0].juzNumber,
              );
            },
          );

    return Stack(
      children: [
        pages,
        Positioned.fill(
          child: SuratPageOverlay(
            onTapTrackerBar: () => _buildTrackerSubmissionDialog(habitNotifier),
            onTapStartTracking: _onTapStartTracking,
          ),
        ),
      ],
    );
  }

  Future<void> _onTapStartTracking() async {
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);

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
          if (!mounted) return;
          _startTracking(context, ref.read(suratPageHabitProvider.notifier));
        });
      }
      return;
    }

    _startTracking(context, habitNotifier);
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
