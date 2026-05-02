import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';

class SuratPageContentState {
  SuratPageContentState({
    this.pages,
    this.fullPageSeparators,
    this.translations,
    this.tafsirs,
    this.latins,
    this.readingSettings,
    this.availableAyahTadabburs = const {},
  });

  final List<QuranPage>? pages;
  final List<FullPageSeparator>? fullPageSeparators;
  final List<List<String>>? translations;
  final List<List<String>>? tafsirs;
  final List<List<String>>? latins;
  final ReadingSettings? readingSettings;
  final Map<int, List<int>> availableAyahTadabburs;

  SuratPageContentState copyWith({
    List<QuranPage>? pages,
    List<FullPageSeparator>? fullPageSeparators,
    List<List<String>>? translations,
    List<List<String>>? tafsirs,
    List<List<String>>? latins,
    ReadingSettings? readingSettings,
    Map<int, List<int>>? availableAyahTadabburs,
  }) {
    return SuratPageContentState(
      pages: pages ?? this.pages,
      fullPageSeparators: fullPageSeparators ?? this.fullPageSeparators,
      translations: translations ?? this.translations,
      tafsirs: tafsirs ?? this.tafsirs,
      latins: latins ?? this.latins,
      readingSettings: readingSettings ?? this.readingSettings,
      availableAyahTadabburs:
          availableAyahTadabburs ?? this.availableAyahTadabburs,
    );
  }
}
