import 'package:flutter/widgets.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/models/reading_settings.dart';

class SuratPageState {
  SuratPageState({
    this.pages,
    this.pageController,
    this.translations,
    this.tafsirs,
    this.latins,
    this.readingSettings,
    this.fullPageSeparators,
    this.isBookmarkFetched = false,
    this.isRecording = false,
    this.isLoading = true,
    this.showMinimizedAudioPlayer = false,
  });

  List<QuranPage>? pages;
  List<FullPageSeparator>? fullPageSeparators;
  List<List<String>>? translations;
  List<List<String>>? tafsirs;
  List<List<String>>? latins;
  PageController? pageController;
  ReadingSettings? readingSettings;
  bool isBookmarkFetched;
  bool isRecording;
  bool isLoading;
  bool showMinimizedAudioPlayer;

  SuratPageState copyWith({
    List<QuranPage>? pages,
    List<FullPageSeparator>? fullPageSeparators,
    PageController? pageController,
    List<List<String>>? translations,
    List<List<String>>? tafsirs,
    List<List<String>>? latins,
    ReadingSettings? readingSettings,
    bool? isBookmarkFetched,
    bool? isRecording,
    bool? isLoading,
    bool? showMinimizedAudioPlayer,
  }) {
    return SuratPageState(
      isBookmarkFetched: isBookmarkFetched ?? this.isBookmarkFetched,
      pages: pages ?? this.pages,
      pageController: pageController ?? this.pageController,
      translations: translations ?? this.translations,
      tafsirs: tafsirs ?? this.tafsirs,
      latins: latins ?? this.latins,
      readingSettings: readingSettings ?? this.readingSettings,
      fullPageSeparators: fullPageSeparators ?? this.fullPageSeparators,
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      showMinimizedAudioPlayer:
          showMinimizedAudioPlayer ?? this.showMinimizedAudioPlayer,
    );
  }

  double get currentPage => pageController!.page!;
}
