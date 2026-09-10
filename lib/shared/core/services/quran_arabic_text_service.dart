import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';

/// Parses the bundled Tanzil "Simple" Quran text into a verse-key -> Arabic map.
///
/// Pure (no I/O) so it can be unit-tested directly. [raw] is the verbatim
/// Tanzil `txt-2` payload: pipe-delimited `surah|ayah|text` verse lines plus a
/// `#` copyright/notice block and blank separator lines, both of which are
/// skipped. Keys are `"$surah:$ayah"` to match `Verse.verseKey`, so a parsed
/// value can be looked up straight from a verse.
Map<String, String> parseTanzilQuranText(String raw) {
  final Map<String, String> result = <String, String>{};
  for (final String line in const LineSplitter().convert(raw)) {
    final String trimmed = line.trim();
    // Skip blank lines and the Tanzil `#` notice block.
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    // Split into exactly 3 fields; the text itself never contains a pipe, but
    // limiting the split guards against any future stray pipe in the payload.
    final int firstPipe = line.indexOf('|');
    if (firstPipe < 0) continue;
    final int secondPipe = line.indexOf('|', firstPipe + 1);
    if (secondPipe < 0) continue;

    final String surah = line.substring(0, firstPipe);
    final String ayah = line.substring(firstPipe + 1, secondPipe);
    final String text = line.substring(secondPipe + 1);
    result['$surah:$ayah'] = text;
  }
  return result;
}

/// Cached loader for the bundled Tanzil "Simple" Unicode Quran text.
///
/// The asset (`data/quran_arabic/quran-simple.txt`) is read once via
/// [rootBundle] and parsed with [parseTanzilQuranText]; subsequent lookups hit
/// the in-memory map. Dependency-light on purpose (a plain cached loader, no
/// riverpod) so it can be constructed anywhere a plain Arabic string is needed.
class QuranArabicTextService {
  /// [loadRaw] is a test seam: it defaults to reading the bundled Tanzil asset
  /// via [rootBundle], but tests inject a fake that fails once then succeeds to
  /// prove a failed load doesn't get stuck cached forever. Never pass it in
  /// production.
  QuranArabicTextService({@visibleForTesting Future<String> Function()? loadRaw})
    : _loadRaw =
          loadRaw ??
          (() => rootBundle.loadString(AppConstants.quranArabicSimpleTxt));

  final Future<String> Function() _loadRaw;

  Map<String, String>? _cache;
  Future<Map<String, String>>? _loading;

  /// Loads and caches the parsed verse map, coalescing concurrent callers onto
  /// a single asset read. On failure (e.g. a transient asset-read error), the
  /// in-flight future is cleared before rethrowing so the next call retries
  /// instead of rethrowing a permanently-cached failure forever.
  Future<Map<String, String>> _ensureLoaded() {
    final Map<String, String>? cached = _cache;
    if (cached != null) return Future<Map<String, String>>.value(cached);

    return _loading ??= () async {
      try {
        final String raw = await _loadRaw();
        final Map<String, String> parsed = parseTanzilQuranText(raw);
        _cache = parsed;
        _loading = null;
        return parsed;
      } catch (_) {
        _loading = null;
        rethrow;
      }
    }();
  }

  /// Returns the Unicode Arabic text for [verseKey] (e.g. `"2:255"`), or null
  /// when the key is not present.
  Future<String?> getArabicByVerseKey(String verseKey) async {
    final Map<String, String> map = await _ensureLoaded();
    return map[verseKey];
  }
}
