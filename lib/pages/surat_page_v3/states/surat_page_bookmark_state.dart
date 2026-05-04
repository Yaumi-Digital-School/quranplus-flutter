class SuratPageBookmarkState {
  const SuratPageBookmarkState({
    this.visibleIconBookmark = false,
    this.isBookmarkChanged = false,
    this.isFavoriteAyahChanged = false,
  });

  final bool visibleIconBookmark;
  final bool isBookmarkChanged;
  final bool isFavoriteAyahChanged;

  SuratPageBookmarkState copyWith({
    bool? visibleIconBookmark,
    bool? isBookmarkChanged,
    bool? isFavoriteAyahChanged,
  }) {
    return SuratPageBookmarkState(
      visibleIconBookmark: visibleIconBookmark ?? this.visibleIconBookmark,
      isBookmarkChanged: isBookmarkChanged ?? this.isBookmarkChanged,
      isFavoriteAyahChanged:
          isFavoriteAyahChanged ?? this.isFavoriteAyahChanged,
    );
  }
}
