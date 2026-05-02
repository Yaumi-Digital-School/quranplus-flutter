import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookmark_page_state_notifier.g.dart';

class BookmarkPageState {
  BookmarkPageState({
    this.listBookmarks,
    this.listFavoriteAyah,
  });

  List<Bookmarks>? listBookmarks;
  List<FavoriteAyahs>? listFavoriteAyah;

  BookmarkPageState copyWith({
    List<Bookmarks>? listBookmarks,
    List<FavoriteAyahs>? listFavoriteAyah,
  }) {
    return BookmarkPageState(
      listBookmarks: listBookmarks ?? this.listBookmarks,
      listFavoriteAyah: listFavoriteAyah ?? this.listFavoriteAyah,
    );
  }
}

@riverpod
class BookmarkPageNotifier extends _$BookmarkPageNotifier {
  @override
  BookmarkPageState build() => BookmarkPageState();

  Future<void> initStateNotifier({
    ConnectivityStatus? connectivityStatus,
  }) async {
    final bookmarksSvc = ref.read(bookmarksService);
    final favoriteAyahsSvc = ref.read(favoriteAyahsService);
    final isLoggedIn =
        ref.read(authenticationService).isLoggedIn;

    if (isLoggedIn && connectivityStatus == ConnectivityStatus.isConnected) {
      await bookmarksSvc.mergeBookmarkToServer();
    }

    final localBookmarks = await bookmarksSvc.getBookmarkFromLocal();
    final localFavoriteAyahs =
        await favoriteAyahsSvc.getFavoriteAyahListLocal();

    state = state.copyWith(
      listBookmarks: localBookmarks,
      listFavoriteAyah: localFavoriteAyahs,
    );
  }

  Future<void> initFavoriteAyahSection() async {
    final localFavoriteAyahs = await ref
        .read(favoriteAyahsService)
        .getFavoriteAyahListLocal();
    state = state.copyWith(listFavoriteAyah: localFavoriteAyahs);
  }

  Future<void> initBookmarkSection({
    ConnectivityStatus? connectivityStatus,
  }) async {
    final bookmarksSvc = ref.read(bookmarksService);
    final isLoggedIn = ref.read(authenticationService).isLoggedIn;

    if (isLoggedIn && connectivityStatus == ConnectivityStatus.isConnected) {
      await bookmarksSvc.mergeBookmarkToServer();
    }

    final localBookmarks = await bookmarksSvc.getBookmarkFromLocal();
    state = state.copyWith(listBookmarks: localBookmarks);
  }
}
