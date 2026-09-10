// Tests for the full-page tap-to-highlight + 1s-hold ayah detail feature:
//  - pure segmentation (parity + grouping) and adjacent-verse resolution;
//  - the AyahDetailBottomSheet (content + sticky prev/next footer);
//  - the tap / 1s-hold interaction on FullPagePagesView.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// google_fonts exposes its http client only from src; overriding it keeps the
// sheet's font fetches from failing the share test under runAsync (see below).
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' show httpClient;
import 'package:qurantafsir_flutter/pages/surat_page_v3/ayah_share_image.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/full_page_ayah_utils.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_navigation_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/ayah_detail_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/surat_page_views.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/core/services/quran_arabic_text_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/theme_state_notifier.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// ---------------------------------------------------------------------------
// Fake data builders
// ---------------------------------------------------------------------------

Word _w(String code, int line) => Word(
  chapterNumber: 1,
  code: code,
  id: 0,
  lineNumber: line,
  wordPosition: 0,
);

Verse _v({required int id, required String key, required List<Word> words}) {
  return Verse(
    hizbNumber: 1,
    id: id,
    juzNumber: 1,
    verseKey: key,
    verseNumber: int.parse(key.split(':')[1]),
    words: words,
  );
}

List<List<String>> _table(String prefix) => List<List<String>>.generate(
  114,
  (int s) => List<String>.generate(300, (int a) => '$prefix$s-$a'),
);

/// An http client whose requests never complete. Installed as google_fonts'
/// [httpClient] in the share test so the sheet's font fetches stay pending
/// (instead of rejecting and failing the test) while the real event loop runs
/// under runAsync for PNG encoding.
class _NeverRespondingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Completer<http.StreamedResponse>().future;
}

// ---------------------------------------------------------------------------
// Fake notifiers
// ---------------------------------------------------------------------------

class _FakeContentNotifier extends SuratPageContentNotifier {
  _FakeContentNotifier(this._seed);
  final SuratPageContentState _seed;

  @override
  SuratPageContentState build() => _seed;
}

class _FakeNavNotifier extends SuratPageNavigationNotifier {
  _FakeNavNotifier(this._seed);
  final SuratPageNavigationState _seed;

  @override
  SuratPageNavigationState build() => _seed;
}

/// The share chooser opens a BaseWidgetBottomSheet, which watches themeProvider
/// (whose real build() reads SharedPreferences). This fake returns a fixed mode
/// so the chooser can render without a seeded prefs store.
class _FakeThemeNotifier extends ThemeNotifier {
  @override
  QPThemeMode build() => QPThemeMode.light;
}

void main() {
  // -------------------------------------------------------------------------
  // §2 segmentation
  // -------------------------------------------------------------------------
  group('segmentFullPageLines', () {
    test('groups contiguous words per verse and preserves order', () {
      final QuranPage page = QuranPage(
        verses: <Verse>[
          _v(
            id: 1,
            key: '1:1',
            words: <Word>[_w('a', 1), _w('b', 1), _w('c', 2)],
          ),
          _v(id: 2, key: '1:2', words: <Word>[_w('d', 2), _w('e', 3)]),
        ],
      );

      final List<List<AyahLineSegment>> lines = segmentFullPageLines(page);

      expect(lines[0].length, 1);
      expect(lines[0][0].ayahId, 1);
      expect(lines[0][0].text, 'ab');

      // Line shared by the tail of verse 1 and the head of verse 2.
      expect(lines[1].length, 2);
      expect(lines[1][0].ayahId, 1);
      expect(lines[1][0].text, 'c');
      expect(lines[1][1].ayahId, 2);
      expect(lines[1][1].text, 'd');

      expect(lines[2].length, 1);
      expect(lines[2][0].ayahId, 2);
      expect(lines[2][0].text, 'e');
    });

    test('parity: joined segments equal the old per-line concatenation', () {
      final QuranPage page = QuranPage(
        verses: <Verse>[
          _v(
            id: 1,
            key: '1:1',
            words: <Word>[_w('a', 1), _w('b', 1), _w('c', 2)],
          ),
          _v(id: 2, key: '1:2', words: <Word>[_w('d', 2), _w('e', 3)]),
        ],
      );

      final List<List<AyahLineSegment>> lines = segmentFullPageLines(page);
      final List<String> joined = List<String>.generate(
        15,
        (int l) => lines[l].map((AyahLineSegment s) => s.text).join(),
      );

      final List<String> old = List<String>.filled(15, '');
      for (final Verse verse in page.verses) {
        for (final Word word in verse.words) {
          old[word.lineNumber - 1] += word.code;
        }
      }

      expect(joined, old);
    });
  });

  // -------------------------------------------------------------------------
  // §6 adjacent-verse resolution
  // -------------------------------------------------------------------------
  group('findVerseById / adjacentVerse', () {
    final List<QuranPage> pages = <QuranPage>[
      QuranPage(
        verses: <Verse>[
          _v(id: 1, key: '1:1', words: <Word>[_w('x', 1)]),
          _v(id: 2, key: '1:2', words: <Word>[_w('x', 2)]),
          _v(id: 3, key: '1:3', words: <Word>[_w('x', 3)]),
        ],
      ),
      QuranPage(
        verses: <Verse>[
          _v(id: 4, key: '1:4', words: <Word>[_w('x', 1)]),
          _v(id: 5, key: '2:1', words: <Word>[_w('x', 2)]),
        ],
      ),
      QuranPage(
        verses: <Verse>[
          _v(id: 6, key: '2:2', words: <Word>[_w('x', 1)]),
        ],
      ),
    ];

    test('findVerseById returns the verse and its page index', () {
      final result = findVerseById(pages, 5);
      expect(result, isNotNull);
      expect(result!.verse.id, 5);
      expect(result.pageIdx, 1);
      expect(findVerseById(pages, 999), isNull);
    });

    test('middle of a page', () {
      expect(adjacentVerse(pages, 2, next: true)!.verse.id, 3);
      expect(adjacentVerse(pages, 2, next: false)!.verse.id, 1);
    });

    test('crossing a page boundary', () {
      final next = adjacentVerse(pages, 3, next: true);
      expect(next!.verse.id, 4);
      expect(next.pageIdx, 1);
    });

    test('crossing a surah boundary', () {
      expect(adjacentVerse(pages, 4, next: true)!.verse.id, 5);
      expect(adjacentVerse(pages, 5, next: false)!.verse.id, 4);
    });

    test('null at the absolute boundaries', () {
      expect(adjacentVerse(pages, 1, next: false), isNull);
      expect(adjacentVerse(pages, 6, next: true), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // §5 the ayah detail bottom sheet
  // -------------------------------------------------------------------------
  group('AyahDetailBottomSheet', () {
    late List<QuranPage> pages;
    late SuratPageContentState content;

    setUp(() {
      pages = <QuranPage>[
        QuranPage(
          verses: <Verse>[
            _v(id: 100, key: '4:14', words: <Word>[_w('bismi', 1)]),
            _v(
              id: 101,
              key: '4:15',
              words: <Word>[_w('alif', 1), _w('lam', 1)],
            ),
            _v(id: 102, key: '4:16', words: <Word>[_w('mim', 1)]),
          ],
        ),
      ];
      content = SuratPageContentState(
        pages: pages,
        translations: _table('T'),
        tafsirs: _table('X'),
        readingSettings: ReadingSettings(),
      );
    });

    Future<ProviderContainer> pumpSheet(
      WidgetTester tester,
      int initialAyahId,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(content),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(const SuratPageNavigationState()),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              // Fresh State per id so initState re-resolves the current verse.
              body: AyahDetailBottomSheet(
                key: ValueKey<int>(initialAyahId),
                initialAyahId: initialAyahId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(AyahDetailBottomSheet)),
        listen: false,
      );
      // The sheet only reads the nav notifier (never watches it), so keep the
      // auto-dispose provider alive for the assertions.
      container.listen(suratPageNavigationProvider, (_, _) {});
      return container;
    }

    testWidgets('renders centered arabic, translation, tafsir and label', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, 101);

      final Text arabic = tester.widget<Text>(
        find.byKey(const Key('ayah_detail_arabic')),
      );
      expect(arabic.textAlign, TextAlign.center);
      expect(arabic.data, 'alif lam'); // page-glyph codes joined by spaces

      // 4:15 -> surahNumberInIndex 3, verseNumberInIndex 14.
      expect(find.text('T3-14'), findsOneWidget);
      expect(find.text('X3-14'), findsOneWidget);

      expect(
        tester.widget<Text>(find.byKey(const Key('ayah_detail_label'))).data,
        "An-Nisa':15",
      );
    });

    testWidgets('chevrons step to adjacent verses and sync the highlight', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpSheet(tester, 101);

      String label() =>
          tester.widget<Text>(find.byKey(const Key('ayah_detail_label'))).data!;

      await tester.tap(find.byKey(const Key('ayah_detail_next')));
      await tester.pumpAndSettle();
      expect(label(), "An-Nisa':16");
      expect(
        container.read(suratPageNavigationProvider).highlightedAyahId,
        102,
      );

      await tester.tap(find.byKey(const Key('ayah_detail_prev')));
      await tester.pumpAndSettle();
      expect(label(), "An-Nisa':15");
    });

    testWidgets('chevrons are disabled at the boundaries', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, 100); // first seeded verse
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('ayah_detail_prev')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('ayah_detail_next')))
            .onPressed,
        isNotNull,
      );

      await pumpSheet(tester, 102); // last seeded verse
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('ayah_detail_next')))
            .onPressed,
        isNull,
      );
    });
  });

  // -------------------------------------------------------------------------
  // AyahDetailBottomSheet — double chevron, page slide, scroll reset, share
  // -------------------------------------------------------------------------
  group('AyahDetailBottomSheet — chevrons / page slide / scroll / share', () {
    // 3-page shape (same as §6): ids 1-3 on page 0, 4-5 on page 1, 6 on page 2.
    List<QuranPage> buildPages() => <QuranPage>[
      QuranPage(
        verses: <Verse>[
          _v(id: 1, key: '1:1', words: <Word>[_w('x', 1)]),
          _v(id: 2, key: '1:2', words: <Word>[_w('x', 2)]),
          _v(id: 3, key: '1:3', words: <Word>[_w('x', 3)]),
        ],
      ),
      QuranPage(
        verses: <Verse>[
          _v(id: 4, key: '1:4', words: <Word>[_w('x', 1)]),
          _v(id: 5, key: '2:1', words: <Word>[_w('x', 2)]),
        ],
      ),
      QuranPage(
        verses: <Verse>[
          _v(id: 6, key: '2:2', words: <Word>[_w('x', 1)]),
        ],
      ),
    ];

    SuratPageContentState buildContent({
      List<QuranPage>? pages,
      List<List<String>>? translations,
      List<List<String>>? tafsirs,
    }) => SuratPageContentState(
      pages: pages ?? buildPages(),
      translations: translations ?? _table('T'),
      tafsirs: tafsirs ?? _table('X'),
      readingSettings: ReadingSettings(),
    );

    Future<ProviderContainer> pumpSheet(
      WidgetTester tester, {
      required int initialAyahId,
      required SuratPageContentState content,
      PageController? pageController,
      bool withPageView = false,
    }) async {
      final Widget sheet = AyahDetailBottomSheet(
        key: ValueKey<int>(initialAyahId),
        initialAyahId: initialAyahId,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(content),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(
                SuratPageNavigationState(
                  pageController: pageController,
                  isLoading: false,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: withPageView
                  // A real PageView bound to the same controller so the sheet's
                  // animateToPage has something attached to drive.
                  ? Column(
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                          child: PageView(
                            controller: pageController,
                            children: const <Widget>[
                              Center(child: Text('p0')),
                              Center(child: Text('p1')),
                              Center(child: Text('p2')),
                            ],
                          ),
                        ),
                        Expanded(child: sheet),
                      ],
                    )
                  : sheet,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(AyahDetailBottomSheet)),
        listen: false,
      );
      container.listen(suratPageNavigationProvider, (_, _) {});
      return container;
    }

    IconData iconOf(WidgetTester tester, String key) =>
        (tester.widget<IconButton>(find.byKey(Key(key))).icon as Icon).icon!;

    testWidgets('double chevron when the adjacent ayah crosses a page', (
      WidgetTester tester,
    ) async {
      // Verse 3 is the last ayah on page 0; next (verse 4) lives on page 1.
      await pumpSheet(tester, initialAyahId: 3, content: buildContent());

      expect(
        iconOf(tester, 'ayah_detail_next'),
        Icons.keyboard_double_arrow_right,
      );
      // Prev (verse 2) is on the same page -> single chevron.
      expect(iconOf(tester, 'ayah_detail_prev'), Icons.chevron_left);
    });

    testWidgets('single chevrons for a mid-page ayah', (
      WidgetTester tester,
    ) async {
      // Verse 2: prev (1) and next (3) are both on page 0.
      await pumpSheet(tester, initialAyahId: 2, content: buildContent());

      expect(iconOf(tester, 'ayah_detail_next'), Icons.chevron_right);
      expect(iconOf(tester, 'ayah_detail_prev'), Icons.chevron_left);
    });

    testWidgets('absolute first ayah keeps a single, disabled prev chevron', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, initialAyahId: 1, content: buildContent());

      expect(iconOf(tester, 'ayah_detail_prev'), Icons.chevron_left);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('ayah_detail_prev')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('stepping across a page boundary slides the mushaf PageView', (
      WidgetTester tester,
    ) async {
      final PageController controller = PageController(initialPage: 0);
      addTearDown(controller.dispose);

      final ProviderContainer container = await pumpSheet(
        tester,
        initialAyahId: 3,
        content: buildContent(),
        pageController: controller,
        withPageView: true,
      );

      await tester.tap(find.byKey(const Key('ayah_detail_next')));
      await tester.pumpAndSettle();

      expect(controller.page, 1.0);
      expect(
        container.read(suratPageNavigationProvider).highlightedAyahId,
        4,
      );
    });

    testWidgets('crossing a page boundary is a no-op when controller is null', (
      WidgetTester tester,
    ) async {
      // Same page-boundary step but no pageController in nav state.
      final ProviderContainer container = await pumpSheet(
        tester,
        initialAyahId: 3,
        content: buildContent(),
      );

      await tester.tap(find.byKey(const Key('ayah_detail_next')));
      await tester.pumpAndSettle(); // would throw if animateToPage NPE'd

      expect(
        container.read(suratPageNavigationProvider).highlightedAyahId,
        4,
      );
    });

    testWidgets('stepping to another ayah resets the scroll position', (
      WidgetTester tester,
    ) async {
      final List<QuranPage> pages = <QuranPage>[
        QuranPage(
          verses: <Verse>[
            _v(id: 100, key: '4:14', words: <Word>[_w('bismi', 1)]),
            _v(id: 101, key: '4:15', words: <Word>[_w('alif', 1)]),
            _v(id: 102, key: '4:16', words: <Word>[_w('mim', 1)]),
          ],
        ),
      ];
      final List<List<String>> translations = _table('T');
      final List<List<String>> tafsirs = _table('X');
      final String long = List<String>.filled(
        80,
        'Lorem ipsum dolor sit amet. ',
      ).join();
      // Verse 101 -> surahNumberInIndex 3, verseNumberInIndex 14.
      translations[3][14] = long;
      tafsirs[3][14] = long;

      await pumpSheet(
        tester,
        initialAyahId: 101,
        content: buildContent(
          pages: pages,
          translations: translations,
          tafsirs: tafsirs,
        ),
      );

      final ScrollableState scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable),
      );
      scrollable.position.jumpTo(200);
      await tester.pump();
      expect(scrollable.position.pixels, 200);

      await tester.tap(find.byKey(const Key('ayah_detail_next')));
      await tester.pumpAndSettle();

      expect(
        tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
        0,
      );
    });

    testWidgets('share button builds an image and invokes the onShare seam', (
      WidgetTester tester,
    ) async {
      Uint8List? sharedBytes;
      String? sharedText;

      // Keep the sheet's google_fonts font fetches pending (rather than failing
      // the test) once the real event loop runs under runAsync for encoding.
      final http.Client originalClient = httpClient;
      httpClient = _NeverRespondingClient();
      addTearDown(() => httpClient = originalClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(buildContent()),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(const SuratPageNavigationState()),
            ),
            themeProvider.overrideWith(() => _FakeThemeNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AyahDetailBottomSheet(
                initialAyahId: 5, // 2:1 -> reference "QS. Al-Baqarah: 1"
                onShare: (Uint8List bytes, String text) async {
                  sharedBytes = bytes;
                  sharedText = text;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final IconButton shareButton = tester.widget<IconButton>(
        find.byKey(const Key('ayah_detail_share')),
      );
      expect(shareButton.onPressed, isNotNull);

      // Tapping share now opens the image/text chooser first.
      await tester.tap(find.byKey(const Key('ayah_detail_share')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ayah_share_image_option')), findsOneWidget);
      expect(find.byKey(const Key('ayah_share_text_option')), findsOneWidget);

      // PNG encoding only completes on the real event loop, and the tapped
      // handler runs in a different zone than this body, so poll the plain
      // result field while yielding to the real loop under runAsync.
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('ayah_share_image_option')));
        for (int i = 0; i < 200 && sharedBytes == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });

      expect(sharedBytes, isNotNull);
      expect(sharedBytes!, isNotEmpty);
      expect(sharedText, contains('Al-Baqarah'));
      expect(
        sharedText,
        endsWith(
          '\n\nShared via Quran Plus\n'
          'Android : https://play.google.com/store/apps/details?id=com.yaumi.qurantafsir.id\n'
          'iOS : https://apps.apple.com/no/app/quranplus-tafsir-tadabbur/id6444388439',
        ),
      );
    });

    testWidgets('share button is disabled while a share is in flight', (
      WidgetTester tester,
    ) async {
      // Keep the sheet's google_fonts font fetches pending (rather than failing
      // the test) once the real event loop runs under runAsync for encoding.
      final http.Client originalClient = httpClient;
      httpClient = _NeverRespondingClient();
      addTearDown(() => httpClient = originalClient);

      bool shareStarted = false;
      bool shareFinished = false;
      bool release = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(buildContent()),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(const SuratPageNavigationState()),
            ),
            themeProvider.overrideWith(() => _FakeThemeNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AyahDetailBottomSheet(
                initialAyahId: 5,
                // Holds the share in flight until the test flips [release], so
                // the button's disabled state can be observed mid-share. Polls a
                // plain flag rather than awaiting a Completer, which is not seen
                // across the fake-async / runAsync zone boundary.
                onShare: (Uint8List bytes, String text) async {
                  shareStarted = true;
                  while (!release) {
                    await Future<void>.delayed(const Duration(milliseconds: 10));
                  }
                  shareFinished = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      IconButton shareButton() => tester.widget<IconButton>(
        find.byKey(const Key('ayah_detail_share')),
      );

      expect(shareButton().onPressed, isNotNull);

      // Open the chooser, then pick "Share as Image".
      await tester.tap(find.byKey(const Key('ayah_detail_share')));
      await tester.pumpAndSettle();

      // Tap image, then wait until the seam is entered (image built, share in
      // flight).
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('ayah_share_image_option')));
        for (int i = 0; i < 200 && !shareStarted; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });
      await tester.pump(); // flush the setState(_isSharing = true) rebuild

      expect(shareStarted, isTrue);
      expect(shareButton().onPressed, isNull);

      // Release the in-flight share; the finally re-enables the button.
      release = true;
      await tester.runAsync(() async {
        for (int i = 0; i < 200 && !shareFinished; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        // Drain the microtasks after the seam returns (the finally's setState).
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump(); // flush the setState(_isSharing = false) rebuild

      expect(shareFinished, isTrue);
      expect(shareButton().onPressed, isNotNull);
    });

    testWidgets('text share composes arabic, translation and reference in order', (
      WidgetTester tester,
    ) async {
      String? sharedText;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(buildContent()),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(const SuratPageNavigationState()),
            ),
            themeProvider.overrideWith(() => _FakeThemeNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AyahDetailBottomSheet(
                initialAyahId: 5, // 2:1 -> "QS. Al-Baqarah: 1"
                onShareText: (String text) async {
                  sharedText = text;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the chooser and pick "Share as Text".
      await tester.tap(find.byKey(const Key('ayah_detail_share')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ayah_share_image_option')), findsOneWidget);
      expect(find.byKey(const Key('ayah_share_text_option')), findsOneWidget);

      // The Arabic must come from the bundled Tanzil asset, so resolve the
      // expected value from the real asset and drive the text flow under the
      // real event loop (rootBundle.loadString needs it).
      String? expectedArabic;
      await tester.runAsync(() async {
        expectedArabic = await QuranArabicTextService().getArabicByVerseKey(
          '2:1',
        );
        await tester.tap(find.byKey(const Key('ayah_share_text_option')));
        for (int i = 0; i < 200 && sharedText == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      });

      expect(expectedArabic, isNotNull);
      expect(sharedText, isNotNull);
      final String text = sharedText!;
      final String arabic = expectedArabic!;

      expect(text, contains(arabic));
      expect(text, contains('T1-0')); // translation for 2:1
      expect(text, contains('QS. Al-Baqarah: 1'));
      expect(
        text,
        endsWith(
          'QS. Al-Baqarah: 1\n\n'
          'Shared via Quran Plus\n'
          'Android : https://play.google.com/store/apps/details?id=com.yaumi.qurantafsir.id\n'
          'iOS : https://apps.apple.com/no/app/quranplus-tafsir-tadabbur/id6444388439',
        ),
      );

      // Top-to-bottom ordering: arabic, translation, reference/tagline.
      expect(text.indexOf(arabic), lessThan(text.indexOf('T1-0')));
      expect(text.indexOf('T1-0'), lessThan(text.indexOf('QS.')));
      expect(
        text.indexOf('QS.'),
        lessThan(text.indexOf('Shared via Quran Plus')),
      );
    });
  });

  // -------------------------------------------------------------------------
  // buildAyahShareImage
  // -------------------------------------------------------------------------
  group('buildAyahShareImage', () {
    testWidgets('produces a non-empty PNG at the fixed width', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final Uint8List bytes = await buildAyahShareImage(
          arabicText: 'alif lam mim',
          arabicFontFamily: 'Page1',
          translation: 'Alif Lam Mim.',
          reference: 'QS. Al-Baqarah: 1',
        );

        expect(bytes, isNotEmpty);
        // PNG magic header.
        expect(bytes.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);

        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        expect(frame.image.width, 1080);
        frame.image.dispose();
        codec.dispose();
      });
    });

    testWidgets('renders even without a translation', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final Uint8List bytes = await buildAyahShareImage(
          arabicText: 'alif',
          arabicFontFamily: 'Page1',
          translation: null,
          reference: 'QS. Al-Baqarah: 1',
        );

        expect(bytes, isNotEmpty);
        expect(bytes.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);
      });
    });

    testWidgets('renders the brand logo and still emits a 1080-wide PNG', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        // A tiny programmatic logo stands in for images/logogram.png.
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final ui.Canvas canvas = ui.Canvas(recorder);
        canvas.drawRect(
          const ui.Rect.fromLTWH(0, 0, 12, 12),
          ui.Paint()..color = const ui.Color(0xFF00A651),
        );
        final ui.Image logo = await recorder.endRecording().toImage(12, 12);

        final Uint8List bytes = await buildAyahShareImage(
          arabicText: 'alif lam mim',
          arabicFontFamily: 'Page1',
          translation: 'Alif Lam Mim.',
          reference: 'QS. Al-Baqarah: 1',
          logo: logo,
        );
        logo.dispose();

        expect(bytes, isNotEmpty);
        // PNG magic header.
        expect(bytes.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);

        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frame = await codec.getNextFrame();
        expect(frame.image.width, 1080);
        frame.image.dispose();
        codec.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // §3 tap / 1s-hold interaction on FullPagePagesView
  // -------------------------------------------------------------------------
  group('FullPagePagesView interaction', () {
    const int targetAyahId = 777;

    List<QuranPage> buildPages() => <QuranPage>[
      QuranPage(
        verses: <Verse>[
          _v(
            id: targetAyahId,
            key: '2:5',
            // Many words on one line so the paragraph fills the line width,
            // making the tap point land on a glyph reliably.
            words: <Word>[for (int i = 0; i < 20; i++) _w('ab', 1)],
          ),
        ],
      ),
      QuranPage(
        verses: <Verse>[
          _v(id: 888, key: '2:6', words: <Word>[_w('zz', 1)]),
        ],
      ),
      QuranPage(
        verses: <Verse>[
          _v(id: 999, key: '2:7', words: <Word>[_w('yy', 1)]),
        ],
      ),
    ];

    Future<ProviderContainer> pumpView(
      WidgetTester tester, {
      required void Function(int ayahId) onHold,
    }) async {
      final List<QuranPage> pages = buildPages();
      final PageController controller = PageController(initialPage: 0);
      addTearDown(controller.dispose);
      final AutoScrollController scrollController = AutoScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(
                SuratPageContentState(
                  pages: pages,
                  readingSettings: ReadingSettings(isInFullPage: true),
                ),
              ),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(
                SuratPageNavigationState(
                  currentPage: 1,
                  pageController: controller,
                  isLoading: false,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: FullPagePagesView(
                orientation: Orientation.portrait,
                scrollController: scrollController,
                onTapToggleCTA: () {},
                onPageChanged: (_) {},
                onAyahLongPressed: onHold,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(
        tester.element(find.byType(FullPagePagesView)),
      );
    }

    Offset glyphPoint(WidgetTester tester) {
      // AutoSizeText fills its box while the (auto-scaled) glyphs sit at the
      // top-left, so target the first glyph's actual box via the paragraph.
      final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('fullpage_line_1_0')),
          matching: find.byType(RichText),
        ),
      );
      final Rect box = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 1),
          )
          .first
          .toRect();
      return paragraph.localToGlobal(box.center);
    }

    testWidgets('tap highlights the ayah and does NOT open the sheet', (
      WidgetTester tester,
    ) async {
      int? held;
      final ProviderContainer container = await pumpView(
        tester,
        onHold: (int id) => held = id,
      );

      await tester.tapAt(glyphPoint(tester));
      await tester.pump();

      expect(
        container.read(suratPageNavigationProvider).highlightedAyahId,
        targetAyahId,
      );
      expect(held, isNull);
    });

    testWidgets('a 1-second hold opens the sheet for the pressed ayah', (
      WidgetTester tester,
    ) async {
      int? held;
      final ProviderContainer container = await pumpView(
        tester,
        onHold: (int id) => held = id,
      );

      final TestGesture gesture = await tester.startGesture(glyphPoint(tester));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 1000));
      await gesture.up();
      await tester.pump();

      expect(held, targetAyahId);
      expect(
        container.read(suratPageNavigationProvider).highlightedAyahId,
        targetAyahId,
      );
    });

    testWidgets('a sub-1s hold highlights but does NOT open the sheet', (
      WidgetTester tester,
    ) async {
      int? held;
      final ProviderContainer container = await pumpView(
        tester,
        onHold: (int id) => held = id,
      );

      final TestGesture gesture = await tester.startGesture(glyphPoint(tester));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump();

      expect(held, isNull);
      expect(
        container.read(suratPageNavigationProvider).highlightedAyahId,
        targetAyahId,
      );
    });
  });
}
