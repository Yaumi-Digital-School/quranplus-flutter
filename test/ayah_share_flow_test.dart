// Tests for the reusable per-ayah share flow (lib/pages/surat_page_v3/
// ayah_share.dart) and its per-ayah entry point:
//  - showAyahShareChooser: the chooser + image/text execution seams;
//  - composeAyahShareText: the pure text-composition unit;
//  - the per-ayah long-press sheet: FavoriteAyahCTA + ShareAyahCTA -> chooser.
//
// Patterns (google_fonts httpClient swap, runAsync polling, fake notifiers) are
// borrowed from test/fullpage_ayah_detail_test.dart and
// test/surat_page_views_lazy_test.dart.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// google_fonts exposes its http client only from src; overriding it keeps the
// image flow's font fetches from failing the share test under runAsync.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' show httpClient;
import 'package:qurantafsir_flutter/pages/surat_page_v3/ayah_share.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_bookmark_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_habit_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_navigation_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/ayah_item_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/quran_arabic_text_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/theme_state_notifier.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

/// The tagline block appended after every share reference (mirrors
/// [kAyahShareTagline] in lib/pages/surat_page_v3/ayah_share.dart).
const String _tagline =
    'Shared via Quran Plus\n'
    'Android : https://play.google.com/store/apps/details?id=com.yaumi.qurantafsir.id\n'
    'iOS : https://apps.apple.com/no/app/quranplus-tafsir-tadabbur/id6444388439';

/// An http client whose requests never complete. Installed as google_fonts'
/// [httpClient] so the image flow's font fetches stay pending (instead of
/// rejecting and failing the test) while PNG encoding runs under runAsync.
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

class _FakeHabitNotifier extends SuratPageHabitNotifier {
  @override
  SuratPageHabitState build() => const SuratPageHabitState();
}

class _FakeBookmarkNotifier extends SuratPageBookmarkNotifier {
  @override
  SuratPageBookmarkState build() => const SuratPageBookmarkState();
}

/// The chooser opens a BaseWidgetBottomSheet, which watches themeProvider
/// (whose real build() reads SharedPreferences). This fake returns a fixed mode
/// so the chooser renders without a seeded prefs store.
class _FakeThemeNotifier extends ThemeNotifier {
  @override
  QPThemeMode build() => QPThemeMode.light;
}

/// Host with a button that opens the share chooser for [verse], so the helper
/// can be exercised with a real [WidgetRef]/[BuildContext] outside any sheet.
class _ShareChooserHost extends ConsumerWidget {
  const _ShareChooserHost({
    required this.verse,
    required this.pageNumberInQuran,
    this.seams,
  });

  final Verse verse;
  final int pageNumberInQuran;
  final AyahShareSeams? seams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('open_chooser'),
          onPressed: () => showAyahShareChooser(
            context: context,
            ref: ref,
            verse: verse,
            pageNumberInQuran: pageNumberInQuran,
            seams: seams,
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  // -------------------------------------------------------------------------
  // composeAyahShareText — pure unit
  // -------------------------------------------------------------------------
  group('composeAyahShareText', () {
    test(
      'arabic, translation, reference and tagline in top-to-bottom order '
      '(exact full string, including both store links and the blank line '
      'before the tagline)',
      () {
        final String text = composeAyahShareText(
          arabic: 'ARABIC',
          translation: 'TRANSLATION',
          reference: 'QS. Al-Baqarah: 1',
        );
        expect(
          text,
          'ARABIC\n\n'
          'TRANSLATION\n\n'
          'QS. Al-Baqarah: 1\n\n'
          'Shared via Quran Plus\n'
          'Android : https://play.google.com/store/apps/details?id=com.yaumi.qurantafsir.id\n'
          'iOS : https://apps.apple.com/no/app/quranplus-tafsir-tadabbur/id6444388439',
        );
      },
    );

    test('null arabic is skipped (no leading blank block)', () {
      final String text = composeAyahShareText(
        arabic: null,
        translation: 'TRANSLATION',
        reference: 'REF',
      );
      expect(text, 'TRANSLATION\n\nREF\n\n$_tagline');
    });

    test('null translation is skipped', () {
      final String text = composeAyahShareText(
        arabic: 'ARABIC',
        translation: null,
        reference: 'REF',
      );
      expect(text, 'ARABIC\n\nREF\n\n$_tagline');
    });

    test('empty / whitespace-only blocks are skipped', () {
      final String text = composeAyahShareText(
        arabic: '   ',
        translation: '',
        reference: 'REF',
      );
      expect(text, 'REF\n\n$_tagline');
    });
  });

  // -------------------------------------------------------------------------
  // showAyahShareChooser — chooser + image/text execution seams
  // -------------------------------------------------------------------------
  group('showAyahShareChooser', () {
    // 2:1 -> "QS. Al-Baqarah: 1"; surahNumberInIndex 1, verseNumberInIndex 0.
    final Verse verse = _v(
      id: 5,
      key: '2:1',
      words: <Word>[_w('alif', 1), _w('lam', 1)],
    );

    SuratPageContentState buildContent() => SuratPageContentState(
      pages: <QuranPage>[
        QuranPage(verses: <Verse>[verse]),
      ],
      // Both tables seeded so ensureAyahDetailContent() is a no-op (no asset
      // loads) and the translation cell resolves to 'T1-0'.
      translations: _table('T'),
      tafsirs: _table('X'),
      readingSettings: ReadingSettings(),
    );

    Future<void> pumpHost(
      WidgetTester tester, {
      required AyahShareSeams seams,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(buildContent()),
            ),
            themeProvider.overrideWith(() => _FakeThemeNotifier()),
          ],
          child: MaterialApp(
            home: _ShareChooserHost(
              verse: verse,
              pageNumberInQuran: 1,
              seams: seams,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('opens a chooser exposing both share options', (
      WidgetTester tester,
    ) async {
      await pumpHost(tester, seams: const AyahShareSeams());

      await tester.tap(find.byKey(const Key('open_chooser')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ayah_share_image_option')), findsOneWidget);
      expect(find.byKey(const Key('ayah_share_text_option')), findsOneWidget);
    });

    testWidgets('image option renders a PNG and invokes the onShareImage seam', (
      WidgetTester tester,
    ) async {
      Uint8List? sharedBytes;
      String? sharedText;

      final http.Client originalClient = httpClient;
      httpClient = _NeverRespondingClient();
      addTearDown(() => httpClient = originalClient);

      await pumpHost(
        tester,
        seams: AyahShareSeams(
          onShareImage: (Uint8List bytes, String text) async {
            sharedBytes = bytes;
            sharedText = text;
          },
        ),
      );

      await tester.tap(find.byKey(const Key('open_chooser')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ayah_share_image_option')), findsOneWidget);

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
      // PNG magic header.
      expect(sharedBytes!.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);
      expect(sharedText, contains('Al-Baqarah'));
      expect(sharedText, endsWith('\n\n$_tagline'));
    });

    testWidgets('text option composes arabic, translation and reference', (
      WidgetTester tester,
    ) async {
      String? sharedText;

      await pumpHost(
        tester,
        seams: AyahShareSeams(
          onShareText: (String text) async {
            sharedText = text;
          },
        ),
      );

      await tester.tap(find.byKey(const Key('open_chooser')));
      await tester.pumpAndSettle();
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
      expect(text, endsWith('QS. Al-Baqarah: 1\n\n$_tagline'));

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
  // Per-ayah long-press sheet — FavoriteAyahCTA + ShareAyahCTA -> chooser
  // -------------------------------------------------------------------------
  group('AyahItemWidget long-press share', () {
    setUp(() {
      // Fire visibility callbacks synchronously so no VisibilityDetector timer
      // is left pending when the widget tree is torn down.
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    });

    Future<void> pumpItem(WidgetTester tester) async {
      final AutoScrollController scrollController = AutoScrollController();
      addTearDown(scrollController.dispose);

      final Verse verse = _v(
        id: 5,
        key: '2:1',
        words: <Word>[_w('ayah', 1)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            suratPageContentProvider.overrideWith(
              () => _FakeContentNotifier(
                SuratPageContentState(
                  pages: <QuranPage>[
                    QuranPage(verses: <Verse>[verse]),
                  ],
                  readingSettings: ReadingSettings(
                    isWithTranslations: false,
                    isWithTafsirs: false,
                    isWithLatins: false,
                  ),
                ),
              ),
            ),
            suratPageNavigationProvider.overrideWith(
              () => _FakeNavNotifier(
                const SuratPageNavigationState(isLoading: false),
              ),
            ),
            suratPageHabitProvider.overrideWith(() => _FakeHabitNotifier()),
            suratPageBookmarkProvider.overrideWith(
              () => _FakeBookmarkNotifier(),
            ),
            internetConnectionStatusProvider.overrideWithValue(
              ConnectivityStatus.isConnected,
            ),
            themeProvider.overrideWith(() => _FakeThemeNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AyahItemWidget(
                verse: verse,
                useDivider: false,
                fontSize: 24,
                pageNumberInQuran: 1,
                orientation: Orientation.portrait,
                scrollController: scrollController,
                startPageInIndex: 5, // != page-1, so no AutoScrollTag wrap
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('long-press shows both Favorite and Share CTAs', (
      WidgetTester tester,
    ) async {
      await pumpItem(tester);

      await tester.longPress(find.text('ayah '));
      await tester.pumpAndSettle();

      expect(find.text('Add to Favorite'), findsOneWidget);
      expect(find.byKey(const Key('ayah_item_share_cta')), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('tapping Share pops the sheet and opens the share chooser', (
      WidgetTester tester,
    ) async {
      await pumpItem(tester);

      await tester.longPress(find.text('ayah '));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('ayah_item_share_cta')));
      await tester.pumpAndSettle();

      // Favorite sheet is gone; the image/text chooser is shown.
      expect(find.text('Add to Favorite'), findsNothing);
      expect(find.byKey(const Key('ayah_share_image_option')), findsOneWidget);
      expect(find.byKey(const Key('ayah_share_text_option')), findsOneWidget);
    });
  });
}
