import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';

class SuratPageContentState {
  SuratPageContentState({
    this.pages,
    this.fullPageSeparators,
    this.separatorsByPage = const {},
    this.translations,
    this.tafsirs,
    this.latins,
    this.readingSettings,
    this.availableAyahTadabburs = const {},
  });

  final List<QuranPage>? pages;
  final List<FullPageSeparator>? fullPageSeparators;

  /// Full page separators grouped by their `page` number, precomputed once so
  /// that full-page rendering can look separators up per page without relying on
  /// a mutable running index that assumes pages build sequentially.
  final Map<int, List<FullPageSeparator>> separatorsByPage;
  final List<List<String>>? translations;
  final List<List<String>>? tafsirs;
  final List<List<String>>? latins;
  final ReadingSettings? readingSettings;
  final Map<int, List<int>> availableAyahTadabburs;

  SuratPageContentState copyWith({
    List<QuranPage>? pages,
    List<FullPageSeparator>? fullPageSeparators,
    Map<int, List<FullPageSeparator>>? separatorsByPage,
    List<List<String>>? translations,
    List<List<String>>? tafsirs,
    List<List<String>>? latins,
    ReadingSettings? readingSettings,
    Map<int, List<int>>? availableAyahTadabburs,
  }) {
    return SuratPageContentState(
      pages: pages ?? this.pages,
      fullPageSeparators: fullPageSeparators ?? this.fullPageSeparators,
      separatorsByPage: separatorsByPage ?? this.separatorsByPage,
      translations: translations ?? this.translations,
      tafsirs: tafsirs ?? this.tafsirs,
      latins: latins ?? this.latins,
      readingSettings: readingSettings ?? this.readingSettings,
      availableAyahTadabburs:
          availableAyahTadabburs ?? this.availableAyahTadabburs,
    );
  }
}
