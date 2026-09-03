import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';

/// A contiguous run of glyph `code`s belonging to a single verse on one mushaf
/// line. Produced by [segmentFullPageLines] so the full-page renderer can build
/// one interactive [TextSpan] per verse while preserving the exact concatenated
/// glyph string the non-interactive renderer used.
class AyahLineSegment {
  AyahLineSegment({
    required this.ayahId,
    required this.surahNumber,
    required this.verseNumber,
    required this.text,
  });

  final int ayahId;
  final int surahNumber;
  final int verseNumber;

  /// Concatenated `word.code`s (no separators — matches the mushaf glyph font).
  String text;

  @override
  String toString() =>
      'AyahLineSegment(ayahId: $ayahId, $surahNumber:$verseNumber, "$text")';
}

/// Segments a full page into 15 lines of per-verse [AyahLineSegment]s.
///
/// Walks verses and their words in order, appending each `word.code` to the
/// line given by `word.lineNumber` (1-based) and grouping contiguous words of
/// the same verse into a single segment. Parity property: joining a line's
/// segment texts (in order, no separator) equals the old per-line concatenation
/// `texts[line]`.
List<List<AyahLineSegment>> segmentFullPageLines(QuranPage page) {
  final List<List<AyahLineSegment>> lines =
      List<List<AyahLineSegment>>.generate(
        15,
        (_) => <AyahLineSegment>[],
        growable: false,
      );

  for (final Verse verse in page.verses) {
    for (final Word word in verse.words) {
      final int lineIndex = word.lineNumber - 1;
      if (lineIndex < 0 || lineIndex >= 15) continue;

      final List<AyahLineSegment> lineSegments = lines[lineIndex];
      if (lineSegments.isNotEmpty && lineSegments.last.ayahId == verse.id) {
        lineSegments.last.text += word.code;
      } else {
        lineSegments.add(
          AyahLineSegment(
            ayahId: verse.id,
            surahNumber: verse.surahNumber,
            verseNumber: verse.verseNumber,
            text: word.code,
          ),
        );
      }
    }
  }

  return lines;
}

/// The verse with the given global [ayahId] plus the index of the page it sits
/// on, or null if not found. Pages are in global quran order.
({Verse verse, int pageIdx})? findVerseById(List<QuranPage> pages, int ayahId) {
  for (int p = 0; p < pages.length; p++) {
    for (final Verse verse in pages[p].verses) {
      if (verse.id == ayahId) {
        return (verse: verse, pageIdx: p);
      }
    }
  }
  return null;
}

/// The verse immediately before/after [ayahId] in global quran order, crossing
/// page and surah boundaries naturally. Returns null at the absolute quran
/// boundaries (before the first ayah / after the last ayah) or if [ayahId] is
/// not found.
({Verse verse, int pageIdx})? adjacentVerse(
  List<QuranPage> pages,
  int ayahId, {
  required bool next,
}) {
  ({Verse verse, int pageIdx})? previous;

  for (int p = 0; p < pages.length; p++) {
    final List<Verse> verses = pages[p].verses;
    for (int i = 0; i < verses.length; i++) {
      final ({Verse verse, int pageIdx}) current = (
        verse: verses[i],
        pageIdx: p,
      );

      if (next) {
        if (previous != null && previous.verse.id == ayahId) {
          return current;
        }
      } else {
        if (current.verse.id == ayahId) {
          return previous;
        }
      }

      previous = current;
    }
  }

  // `next` for the very last verse falls through to here → no successor.
  return null;
}
