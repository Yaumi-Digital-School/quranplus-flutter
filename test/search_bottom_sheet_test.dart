// Regression tests for the homepage search bottom sheet.
//
// SearchBottomSheet is pumped directly (NOT via SearchBottomSheet.show(), which
// wraps it in BaseWidgetBottomSheet and drags in themeProvider). The parsing /
// selection logic is observed through the `onSearch` callback seam instead of a
// real navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/widgets/search_bottom_sheet.dart';

// Fake verseMapper: key = surah number string, value = "ayah:page:ayahID".
final Map<String, List<String>> _fakeVerseMapper = <String, List<String>>{
  '1': <String>['1:1:1', '2:1:2', '3:1:3', '4:1:4', '5:1:5', '6:1:6', '7:1:7'],
  '2': <String>['1:2:8', '2:2:9', '3:3:10'],
  // 11 ayahs, so a `contains` filter on "1" matches 1, 10 and 11.
  '3': <String>[
    '1:5:300',
    '2:5:301',
    '3:5:302',
    '4:5:303',
    '5:5:304',
    '6:5:305',
    '7:5:306',
    '8:5:307',
    '9:5:308',
    '10:5:309',
    '11:6:310',
  ],
  '114': <String>['1:604:200', '2:604:201'],
};

Future<void> _pumpSheet(
  WidgetTester tester, {
  void Function(SuratPageV3Param param)? onSearch,
}) async {
  // Use a phone-sized viewport so the 45%-height option columns are tall
  // enough to build all the rows the assertions tap (the default 600px surface
  // is too short and ListView.builder would skip off-screen rows).
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SearchBottomSheet(
          verseMapper: _fakeVerseMapper,
          onSearch: onSearch,
        ),
      ),
    ),
  );
}

Future<void> _openAyahTab(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(Tab, 'Ayah'));
  await tester.pumpAndSettle();
}

/// Pumps the sheet inside a harness that mimics BaseWidgetBottomSheet with the
/// keyboard open: a phone-sized screen (900 logical tall) with a large keyboard
/// inset (1200 physical / dpr 3 = 400 logical), bottom-aligned, padded by
/// viewInsets.bottom, with a bit of fixed chrome above the sheet.
Future<void> _pumpKeyboardSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2700);
  tester.view.devicePixelRatio = 3.0;
  tester.view.viewInsets = const FakeViewPadding(bottom: 1200);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        // Replicate the sheet's real behavior: the surrounding chrome pads by
        // viewInsets.bottom itself, so the Scaffold must not also inset.
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            final MediaQueryData mq = MediaQuery.of(context);
            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: mq.size.height),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: mq.viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      const SizedBox(height: 5, width: 40),
                      const SizedBox(height: 20),
                      SearchBottomSheet(verseMapper: _fakeVerseMapper),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Ayah tab filters the surah column and shows "Surah not found"', (
    WidgetTester tester,
  ) async {
    await _pumpSheet(tester);
    await _openAyahTab(tester);

    // All surahs visible initially.
    expect(find.text('1. Al-Fatihah'), findsOneWidget);
    expect(find.text('2. Al-Baqarah'), findsOneWidget);

    // Filtering by a label fragment narrows the surah column.
    await tester.enterText(find.byKey(const Key('search_surah_field')), 'Al-F');
    await tester.pump();
    expect(find.text('1. Al-Fatihah'), findsOneWidget);
    expect(find.text('2. Al-Baqarah'), findsNothing);

    // A non-matching query surfaces the not-found hint.
    await tester.enterText(find.byKey(const Key('search_surah_field')), 'zzz');
    await tester.pump();
    expect(find.text('Surah not found'), findsOneWidget);
  });

  testWidgets(
    'Selecting a surah populates the ayah column and default selection '
    'navigates to ayah 1',
    (WidgetTester tester) async {
      SuratPageV3Param? captured;
      await _pumpSheet(tester, onSearch: (param) => captured = param);
      await _openAyahTab(tester);

      await tester.tap(find.text('1. Al-Fatihah'));
      await tester.pump();

      // Right column now shows the surah's 7 ayahs.
      expect(find.text('7 Ayah'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('search_ayah_list')),
          matching: find.text('7'),
        ),
        findsOneWidget,
      );

      // Search is enabled; default selection is ayah 1 (page 1, ayahID 1).
      await tester.tap(find.byKey(const Key('search_button_ayah')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.startPageInIndex, 0); // page 1 - 1
      expect(captured!.firstPagePointerIndex, 1); // ayahID
    },
  );

  testWidgets(
    'Selecting a different ayah row then searching pins its page + ayahID',
    (WidgetTester tester) async {
      SuratPageV3Param? captured;
      await _pumpSheet(tester, onSearch: (param) => captured = param);
      await _openAyahTab(tester);

      await tester.tap(find.text('2. Al-Baqarah'));
      await tester.pump();

      // Ayah 3 of surah 2 is entry "3:3:10" -> page 3, ayahID 10.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('search_ayah_list')),
          matching: find.text('3'),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('search_button_ayah')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.startPageInIndex, 2); // page 3 - 1
      expect(captured!.firstPagePointerIndex, 10); // ayahID
    },
  );

  testWidgets(
    'Page tab clamps out-of-range input, searches page-1, and survives empty '
    'input',
    (WidgetTester tester) async {
      SuratPageV3Param? captured;
      await _pumpSheet(tester, onSearch: (param) => captured = param);

      // Ayah is the initial tab now, so switch to Page first.
      await tester.tap(find.widgetWithText(Tab, 'Page'));
      await tester.pumpAndSettle();

      final Finder pageField = find.byKey(const Key('search_page_field'));

      // Out-of-range value is clamped to the max page.
      await tester.enterText(pageField, '999');
      await tester.pump();
      expect(tester.widget<TextField>(pageField).controller!.text, '604');

      // Empty input must not crash (the old int.parse('') did).
      await tester.enterText(pageField, '');
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.widget<TextField>(pageField).controller!.text, '');

      // A valid page searches with startPageInIndex == page - 1.
      await tester.enterText(pageField, '5');
      await tester.pump();
      await tester.tap(find.byKey(const Key('search_button_page')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.startPageInIndex, 4); // page 5 - 1
      expect(captured!.firstPagePointerIndex, 0); // page tab: no ayah pointer
    },
  );

  testWidgets('Ayah field is disabled until a surah is selected', (
    WidgetTester tester,
  ) async {
    await _pumpSheet(tester);
    await _openAyahTab(tester);

    // Before selecting a surah the ayah field is disabled.
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('search_ayah_field')))
          .enabled,
      isFalse,
    );

    await tester.tap(find.text('1. Al-Fatihah'));
    await tester.pump();

    // Selecting a surah enables it.
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('search_ayah_field')))
          .enabled,
      isTrue,
    );
  });

  testWidgets(
    'Typing an exact ayah number auto-selects it; Search reports that ayah',
    (WidgetTester tester) async {
      SuratPageV3Param? captured;
      await _pumpSheet(tester, onSearch: (param) => captured = param);
      await _openAyahTab(tester);

      await tester.tap(find.text('1. Al-Fatihah'));
      await tester.pump();

      // Surah 1 entry "5:1:5" -> page 1, ayahID 5.
      await tester.enterText(find.byKey(const Key('search_ayah_field')), '5');
      await tester.pump();

      await tester.tap(find.byKey(const Key('search_button_ayah')));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.startPageInIndex, 0); // page 1 - 1
      expect(captured!.firstPagePointerIndex, 5); // ayahID of ayah 5
    },
  );

  testWidgets('Typing an over-max ayah number clamps to the ayah count', (
    WidgetTester tester,
  ) async {
    await _pumpSheet(tester);
    await _openAyahTab(tester);

    await tester.tap(find.text('1. Al-Fatihah')); // 7 ayahs
    await tester.pump();

    await tester.enterText(find.byKey(const Key('search_ayah_field')), '99');
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('search_ayah_field')))
          .controller!
          .text,
      '7',
    );
  });

  testWidgets('Ayah field filters the visible ayah rows by contains', (
    WidgetTester tester,
  ) async {
    await _pumpSheet(tester);
    await _openAyahTab(tester);

    // Surah 3 has 11 ayahs.
    await tester.tap(find.text("3. Ali 'Imran"));
    await tester.pump();

    final Finder ayahList = find.byKey(const Key('search_ayah_list'));
    // Sanity: unfiltered shows ayah 2.
    expect(
      find.descendant(of: ayahList, matching: find.text('2')),
      findsOneWidget,
    );

    // `contains('1')` keeps 1, 10 and 11 but drops 2.
    await tester.enterText(find.byKey(const Key('search_ayah_field')), '1');
    await tester.pump();

    expect(
      find.descendant(of: ayahList, matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ayahList, matching: find.text('10')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ayahList, matching: find.text('11')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ayahList, matching: find.text('2')),
      findsNothing,
    );
  });

  testWidgets('Sheet does not overflow when the keyboard is open', (
    WidgetTester tester,
  ) async {
    await _pumpKeyboardSheet(tester);

    expect(
      tester.takeException(),
      isNull,
      reason: 'keyboard open must not overflow the sheet',
    );
  });

  testWidgets('Option lists stay usable while the keyboard is open', (
    WidgetTester tester,
  ) async {
    await _pumpKeyboardSheet(tester);

    // No overflow, and the surah list must keep a usable height rather than
    // being squeezed to a sliver by the keyboard-aware content clamp.
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('search_surah_list'))).height,
      greaterThanOrEqualTo(150),
    );
  });

  testWidgets('Surah and ayah fields are aligned and equal height', (
    WidgetTester tester,
  ) async {
    await _pumpSheet(tester);
    await _openAyahTab(tester);
    await tester.tap(find.text('1. Al-Fatihah'));
    await tester.pump();

    final Finder surahField = find.byKey(const Key('search_surah_field'));
    final Finder ayahField = find.byKey(const Key('search_ayah_field'));

    expect(tester.getTopLeft(surahField).dy, tester.getTopLeft(ayahField).dy);
    expect(tester.getSize(surahField).height, tester.getSize(ayahField).height);
  });

  testWidgets(
    'Surah and ayah lists share the same top, even when "Surah not found"',
    (WidgetTester tester) async {
      await _pumpSheet(tester);
      await _openAyahTab(tester);
      await tester.tap(find.text('1. Al-Fatihah'));
      await tester.pump();

      final Finder surahList = find.byKey(const Key('search_surah_list'));
      final Finder ayahList = find.byKey(const Key('search_ayah_list'));

      expect(tester.getTopLeft(surahList).dy, tester.getTopLeft(ayahList).dy);

      // Showing the not-found status must not shift the lists out of alignment.
      await tester.enterText(
        find.byKey(const Key('search_surah_field')),
        'zzz',
      );
      await tester.pump();
      expect(find.text('Surah not found'), findsOneWidget);
      expect(tester.getTopLeft(surahList).dy, tester.getTopLeft(ayahList).dy);
    },
  );
}
