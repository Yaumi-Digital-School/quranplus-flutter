import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class SuratPageNavigationState extends Equatable {
  const SuratPageNavigationState({
    this.currentPage = 1,
    this.visibleSuratName = '',
    this.visibleJuzNumber = 1,
    this.pageController,
    this.isLoading = true,
    this.highlightedAyahId,
  });

  final int currentPage;
  final String visibleSuratName;
  final int visibleJuzNumber;
  final PageController? pageController;
  final bool isLoading;

  /// Global ayah id of the currently highlighted ayah in full-page mode, or
  /// null when nothing is highlighted. Cleared via
  /// `SuratPageNavigationNotifier.clearHighlightedAyah()` (copyWith cannot set
  /// it back to null).
  final int? highlightedAyahId;

  SuratPageNavigationState copyWith({
    int? currentPage,
    String? visibleSuratName,
    int? visibleJuzNumber,
    PageController? pageController,
    bool? isLoading,
    int? highlightedAyahId,
  }) {
    return SuratPageNavigationState(
      currentPage: currentPage ?? this.currentPage,
      visibleSuratName: visibleSuratName ?? this.visibleSuratName,
      visibleJuzNumber: visibleJuzNumber ?? this.visibleJuzNumber,
      pageController: pageController ?? this.pageController,
      isLoading: isLoading ?? this.isLoading,
      highlightedAyahId: highlightedAyahId ?? this.highlightedAyahId,
    );
  }

  @override
  List<Object?> get props => [
    currentPage,
    visibleSuratName,
    visibleJuzNumber,
    pageController,
    isLoading,
    highlightedAyahId,
  ];
}
