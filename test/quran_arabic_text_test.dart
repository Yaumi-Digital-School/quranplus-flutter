// Tests for the bundled Tanzil "Simple" Unicode Quran text:
//  - the pure parser seam (parseTanzilQuranText);
//  - the real bundled asset's integrity (loaded via rootBundle).

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/services/quran_arabic_text_service.dart';

void main() {
  // -------------------------------------------------------------------------
  // parseTanzilQuranText (pure)
  // -------------------------------------------------------------------------
  group('parseTanzilQuranText', () {
    test('parses verse lines and skips comment / blank lines', () {
      const String raw =
          '# Tanzil Quran Text (Simple, Version 1.1)\n'
          '# Copyright (C) Tanzil Project\n'
          '\n'
          '1|1|بِسْمِ اللَّهِ\n'
          '1|2|الْحَمْدُ لِلَّهِ\n'
          '2|1|الم\n'
          '\n'
          '# PLEASE DO NOT REMOVE OR CHANGE THIS COPYRIGHT BLOCK\n';

      final Map<String, String> map = parseTanzilQuranText(raw);

      expect(map.length, 3);
      expect(map['1:1'], 'بِسْمِ اللَّهِ');
      expect(map['1:2'], 'الْحَمْدُ لِلَّهِ');
      expect(map['2:1'], 'الم');
      // Comment/blank lines never become keys.
      expect(map.containsKey('#:'), isFalse);
    });

    test('keeps pipes inside the verse text intact', () {
      // The text field is everything after the second pipe.
      final Map<String, String> map = parseTanzilQuranText('3|7|a|b');
      expect(map['3:7'], 'a|b');
    });

    test('empty input yields an empty map', () {
      expect(parseTanzilQuranText(''), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Bundled asset integrity (real asset via rootBundle)
  // -------------------------------------------------------------------------
  group('bundled quran-simple.txt asset', () {
    testWidgets('parses to the full 6236-verse Quran', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final String raw = await rootBundle.loadString(
          AppConstants.quranArabicSimpleTxt,
        );
        final Map<String, String> map = parseTanzilQuranText(raw);

        expect(map.length, 6236);
        expect(map['1:1'], contains('بِسْمِ'));
        expect(map['2:286'], isNotNull);
        expect(map['2:286'], isNotEmpty);
        expect(map['114:6'], isNotNull);
        expect(map['114:6'], isNotEmpty);
      });
    });

    testWidgets('QuranArabicTextService resolves a verse from the asset', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        final QuranArabicTextService service = QuranArabicTextService();
        final String? basmalah = await service.getArabicByVerseKey('1:1');
        expect(basmalah, isNotNull);
        expect(basmalah, contains('بِسْمِ'));
        expect(await service.getArabicByVerseKey('999:999'), isNull);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Failure recovery (injected loadRaw seam)
  // -------------------------------------------------------------------------
  group('QuranArabicTextService failure recovery', () {
    testWidgets(
      'a failed load does not stay stuck: the next call retries and succeeds',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          int calls = 0;
          final QuranArabicTextService service = QuranArabicTextService(
            loadRaw: () async {
              calls++;
              if (calls == 1) {
                throw Exception('transient asset read failure');
              }
              return '1|1|بِسْمِ اللَّهِ\n';
            },
          );

          // First call: the loader throws, so the lookup must propagate the
          // failure rather than swallowing it (callers decide how to degrade).
          await expectLater(
            service.getArabicByVerseKey('1:1'),
            throwsA(isException),
          );

          // Second call: proves the failed future was reset (not cached
          // forever) by actually succeeding via the loader's second branch.
          final String? basmalah = await service.getArabicByVerseKey('1:1');
          expect(basmalah, 'بِسْمِ اللَّهِ');
          expect(calls, 2);
        });
      },
    );
  });
}
