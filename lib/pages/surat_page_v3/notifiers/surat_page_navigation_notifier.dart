import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_navigation_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'surat_page_navigation_notifier.g.dart';

@riverpod
class SuratPageNavigationNotifier extends _$SuratPageNavigationNotifier {
  late int _startPageInIndex;
  int _currentSurahNumber = 0;
  final List<int> _firstPageSurahPointer = <int>[];

  // Public mutable field used during full-page rendering build cycle
  int separatorBuilderIndex = 0;

  List<int> get firstPageKeys => _firstPageSurahPointer;

  @override
  SuratPageNavigationState build() => SuratPageNavigationState();

  void init(int startPageInIndex) {
    _startPageInIndex = startPageInIndex;
  }

  void initNavigation() {
    final pages = ref.read(suratPageContentProvider).pages!;
    final firstVerse = pages[_startPageInIndex].verses[0];
    _currentSurahNumber = firstVerse.surahNumber;

    state = SuratPageNavigationState(
      currentPage: _startPageInIndex + 1,
      visibleSuratName: surahNumberToSurahNameMap[firstVerse.surahNumber]!,
      visibleJuzNumber: firstVerse.juzNumber,
      pageController: PageController(
        initialPage: _startPageInIndex,
      ),
      isLoading: false,
    );

    ref
        .read(suratPageBookmarkProvider.notifier)
        .checkIsBookmarkExists(_startPageInIndex + 1);
  }

  void recreatePageController() {
    state = state.copyWith(
      pageController: PageController(initialPage: state.currentPage - 1),
    );
  }

  void updateOnPageChanged(int pageIndex, List<QuranPage> pages) {
    final int pageValue = pageIndex + 1;
    final surahNumber = pages[pageIndex].verses[0].surahNumber;
    state = state.copyWith(
      currentPage: pageValue,
      visibleSuratName: surahNumberToSurahNameMap[surahNumber] ?? '',
      visibleJuzNumber: pages[pageIndex].verses[0].juzNumber,
    );
  }

  void updateCurrentPage(int pageValue) {
    state = state.copyWith(currentPage: pageValue);
  }

  void updateVisibleJuz(int juzNumber) {
    if (state.visibleJuzNumber != juzNumber) {
      state = state.copyWith(visibleJuzNumber: juzNumber);
    }
  }

  void updateVisibleSurah(int surahNumber) {
    if (_currentSurahNumber != surahNumber) {
      _currentSurahNumber = surahNumber;
      state = state.copyWith(
        visibleSuratName: surahNumberToSurahNameMap[surahNumber]!,
      );
    }
  }

  void resetSeparatorBuilderIndex() {
    separatorBuilderIndex = 0;
  }

  void addFirstPagePointer(int value) => _firstPageSurahPointer.add(value);

  int getJuzAtStartOfPage({required int pageInIdx}) {
    final pages = ref.read(suratPageContentProvider).pages;
    return pages![pageInIdx].verses[0].juzNumber;
  }

  String getSuratNameAtStartOfPage({required int pageInIdx}) {
    final pages = ref.read(suratPageContentProvider).pages;
    return surahNumberToSurahNameMap[pages![pageInIdx].verses[0].surahNumber]!;
  }
}
