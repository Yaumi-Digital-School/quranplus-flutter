class SuratPageRecitationState {
  SuratPageRecitationState({
    this.showMinimized = false,
  });

  bool showMinimized;

  SuratPageRecitationState copyWith({
    bool showMinimized = false,
  }) {
    return SuratPageRecitationState(
      showMinimized: showMinimized,
    );
  }
}
