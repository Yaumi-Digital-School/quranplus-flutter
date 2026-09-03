// Tripwire regression test guarding lazy page building in surat_page_v3.
//
// The surat page renders all 604 quran pages inside a PageView. Building every
// page eagerly (concatenating every word of the whole quran / constructing
// ~6236 AyahItemWidgets on every rebuild) is what causes the swipe jank.
//
// This test seeds 604 pages where every page OUTSIDE a small window around the
// start page carries a `verses` list that THROWS on any access. If the view
// builds pages lazily (only the visible page + a few neighbours) the tripwire
// pages are never touched and the test stays green. If the view builds pages
// eagerly it detonates a tripwire and the test goes red.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_bookmark_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_habit_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_navigation_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/surat_page_views.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

const int _kTotalPages = 604;
const int _kStartPageInIndex = 300;
const int _kWindow = 5;

/// A `List<Verse>` that throws on any access. Used to mark quran pages that must
/// NOT be built during a lazy render.
class _TripwireVerseList extends ListBase<Verse> {
  _TripwireVerseList(this.pageNumber);

  final int pageNumber;

  Never _boom() =>
      throw StateError('Tripwire: page $pageNumber should not have been built');

  @override
  int get length => _boom();

  @override
  set length(int newLength) => _boom();

  @override
  Verse operator [](int index) => _boom();

  @override
  void operator []=(int index, Verse value) => _boom();
}

Verse _fakeVerse(int pageNumber) => Verse(
  hizbNumber: 1,
  id: pageNumber * 1000,
  juzNumber: 1,
  verseKey: '1:1',
  verseNumber: 1,
  words: <Word>[
    Word(chapterNumber: 1, code: 'x', id: 1, lineNumber: 1, wordPosition: 1),
  ],
);

List<QuranPage> _buildFakePages() {
  return List<QuranPage>.generate(_kTotalPages, (int idx) {
    final int pageNumber = idx + 1;
    final bool nearStart = (idx - _kStartPageInIndex).abs() <= _kWindow;
    if (nearStart) {
      return QuranPage(verses: <Verse>[_fakeVerse(pageNumber)]);
    }
    return QuranPage(verses: _TripwireVerseList(pageNumber));
  });
}

class _FakeContentNotifier extends SuratPageContentNotifier {
  _FakeContentNotifier({required this.pages, required this.isInFullPage});

  final List<QuranPage> pages;
  final bool isInFullPage;

  @override
  SuratPageContentState build() {
    return SuratPageContentState(
      pages: pages,
      fullPageSeparators: const [],
      readingSettings: ReadingSettings(
        isWithTafsirs: false,
        isWithLatins: false,
        isWithTranslations: false,
        isInFullPage: isInFullPage,
      ),
    );
  }
}

class _FakeNavNotifier extends SuratPageNavigationNotifier {
  _FakeNavNotifier(this.controller);

  final PageController controller;

  @override
  SuratPageNavigationState build() {
    return SuratPageNavigationState(
      currentPage: _kStartPageInIndex + 1,
      visibleSuratName: 'Al-Fatihah',
      visibleJuzNumber: 1,
      pageController: controller,
      isLoading: false,
    );
  }
}

class _FakeHabitNotifier extends SuratPageHabitNotifier {
  @override
  SuratPageHabitState build() => const SuratPageHabitState();
}

class _FakeBookmarkNotifier extends SuratPageBookmarkNotifier {
  @override
  SuratPageBookmarkState build() => const SuratPageBookmarkState();
}

Future<void> _pumpView(
  WidgetTester tester, {
  required Widget child,
  required List<QuranPage> pages,
  required PageController controller,
  required bool isInFullPage,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        suratPageContentProvider.overrideWith(
          () => _FakeContentNotifier(pages: pages, isInFullPage: isInFullPage),
        ),
        suratPageNavigationProvider.overrideWith(
          () => _FakeNavNotifier(controller),
        ),
        suratPageHabitProvider.overrideWith(() => _FakeHabitNotifier()),
        suratPageBookmarkProvider.overrideWith(() => _FakeBookmarkNotifier()),
        internetConnectionStatusProvider.overrideWithValue(
          ConnectivityStatus.isConnected,
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  setUp(() {
    // Fire visibility callbacks synchronously so no VisibilityDetector timer is
    // left pending when the widget tree is torn down at the end of a test.
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets(
    'FullPagePagesView builds lazily and never touches off-window pages',
    (WidgetTester tester) async {
      final PageController controller = PageController(
        initialPage: _kStartPageInIndex,
      );
      addTearDown(controller.dispose);
      final AutoScrollController scrollController = AutoScrollController();
      addTearDown(scrollController.dispose);
      final List<QuranPage> pages = _buildFakePages();

      await _pumpView(
        tester,
        pages: pages,
        controller: controller,
        isInFullPage: true,
        child: FullPagePagesView(
          orientation: Orientation.portrait,
          scrollController: scrollController,
          onTapToggleCTA: () {},
          onPageChanged: (_) {},
        ),
      );
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'initial build must be lazy (only pages near the start page)',
      );

      if (controller.hasClients) {
        controller.jumpToPage(_kStartPageInIndex + 1);
        await tester.pump();
      }

      expect(
        tester.takeException(),
        isNull,
        reason: 'swiping forward must not build far-away pages',
      );
    },
  );

  testWidgets(
    'PerAyahPagesView builds lazily and never touches off-window pages',
    (WidgetTester tester) async {
      final PageController controller = PageController(
        initialPage: _kStartPageInIndex,
      );
      addTearDown(controller.dispose);
      final AutoScrollController scrollController = AutoScrollController();
      addTearDown(scrollController.dispose);
      final List<QuranPage> pages = _buildFakePages();

      await _pumpView(
        tester,
        pages: pages,
        controller: controller,
        isInFullPage: false,
        child: PerAyahPagesView(
          orientation: Orientation.portrait,
          scrollController: scrollController,
          startPageInIndex: _kStartPageInIndex,
          onPageChanged: (_) {},
        ),
      );
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'initial build must be lazy (only pages near the start page)',
      );

      if (controller.hasClients) {
        controller.jumpToPage(_kStartPageInIndex + 1);
        await tester.pump();
      }

      expect(
        tester.takeException(),
        isNull,
        reason: 'swiping forward must not build far-away pages',
      );
    },
  );
}
