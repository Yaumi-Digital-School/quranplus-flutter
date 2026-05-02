import 'package:flutter/widgets.dart';

class SuratPageNavigationState {
  SuratPageNavigationState({
    this.currentPage = 1,
    this.visibleSuratName = '',
    this.visibleJuzNumber = 1,
    this.pageController,
    this.isLoading = true,
  });

  final int currentPage;
  final String visibleSuratName;
  final int visibleJuzNumber;
  final PageController? pageController;
  final bool isLoading;

  SuratPageNavigationState copyWith({
    int? currentPage,
    String? visibleSuratName,
    int? visibleJuzNumber,
    PageController? pageController,
    bool? isLoading,
  }) {
    return SuratPageNavigationState(
      currentPage: currentPage ?? this.currentPage,
      visibleSuratName: visibleSuratName ?? this.visibleSuratName,
      visibleJuzNumber: visibleJuzNumber ?? this.visibleJuzNumber,
      pageController: pageController ?? this.pageController,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
