// Tests for the full-page tap-to-highlight + 1s-hold ayah detail feature:
//  - pure segmentation (parity + grouping) and adjacent-verse resolution;
//  - the AyahDetailBottomSheet (content + sticky prev/next footer);
//  - the tap / 1s-hold interaction on FullPagePagesView.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/full_page_ayah_utils.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_navigation_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/ayah_detail_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/surat_page_views.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
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
