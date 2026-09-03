import 'package:equatable/equatable.dart';

class SuratPageBookmarkState extends Equatable {
  const SuratPageBookmarkState({
    this.visibleIconBookmark = false,
    this.isBookmarkChanged = false,
    this.isFavoriteAyahChanged = false,
    this.favoriteAyahsRevision = 0,
  });

  final bool visibleIconBookmark;
  final bool isBookmarkChanged;
  final bool isFavoriteAyahChanged;

  /// Bumped whenever the set of favorited ayahs changes, so that
  /// [AyahItemWidget]s can watch a narrow signal to refresh their favorite icon
  /// without depending on ancestor rebuilds.
  final int favoriteAyahsRevision;

  SuratPageBookmarkState copyWith({
    bool? visibleIconBookmark,
    bool? isBookmarkChanged,
    bool? isFavoriteAyahChanged,
    int? favoriteAyahsRevision,
  }) {
    return SuratPageBookmarkState(
      visibleIconBookmark: visibleIconBookmark ?? this.visibleIconBookmark,
      isBookmarkChanged: isBookmarkChanged ?? this.isBookmarkChanged,
      isFavoriteAyahChanged:
          isFavoriteAyahChanged ?? this.isFavoriteAyahChanged,
      favoriteAyahsRevision:
          favoriteAyahsRevision ?? this.favoriteAyahsRevision,
    );
  }

  @override
  List<Object?> get props => [
    visibleIconBookmark,
    isBookmarkChanged,
    isFavoriteAyahChanged,
    favoriteAyahsRevision,
  ];
}
