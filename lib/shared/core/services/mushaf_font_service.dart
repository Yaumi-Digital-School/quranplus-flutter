import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Preloads the per-page mushaf fonts (`Page1`..`Page604`).
///
/// The fonts are declared in pubspec.yaml, but Flutter registers asset fonts
/// lazily: the first layout using a family parses its TTF synchronously on the
/// UI thread. In the full-page reader that parse lands mid-swipe (the adjacent
/// page is pre-built during the drag), causing jank on every first visit to a
/// page. Registering the same bytes ahead of time via [FontLoader] moves that
/// cost off the gesture; if a preload fails or the user out-swipes it, the
/// engine's lazy load still applies, so text always renders.
class MushafFontService {
  static const int _totalPages = 604;
  static const int _preloadRadius = 2;

  final Set<int> _loadedOrInFlight = <int>{};
  bool _surahNameFontRequested = false;

  /// Preloads fonts for [page] and its neighbors (page ± [_preloadRadius]).
  Future<void> preloadAroundPage(int page) {
    final List<Future<void>> futures = <Future<void>>[];
    for (int p = page - _preloadRadius; p <= page + _preloadRadius; p++) {
      if (p < 1 || p > _totalPages) continue;
      if (!_loadedOrInFlight.add(p)) continue;
      futures.add(_loadFont('Page$p', 'data/quran_fonts/p$p.ttf', p));
    }
    return Future.wait(futures);
  }

  /// Preloads the `SurahName` family used for surah-header lines.
  Future<void> preloadSurahNameFont() {
    if (_surahNameFontRequested) return Future.value();
    _surahNameFontRequested = true;
    return _loadFont('SurahName', 'data/full_page_separator/surah.ttf', null);
  }

  Future<void> _loadFont(String family, String asset, int? page) async {
    try {
      final FontLoader loader = FontLoader(family)
        ..addFont(rootBundle.load(asset));
      await loader.load();
    } catch (e) {
      // Allow a retry on a later page change; rendering is unaffected because
      // the engine falls back to lazily loading the pubspec-declared font.
      if (page != null) {
        _loadedOrInFlight.remove(page);
      } else {
        _surahNameFontRequested = false;
      }
      debugPrint('Mushaf font preload failed for $family: $e');
    }
  }
}
