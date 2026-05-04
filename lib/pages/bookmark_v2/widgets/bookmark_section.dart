import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/widgets/bookmark_empty_state.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/widgets/bookmark_list_item.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';

class BookmarkSection extends ConsumerWidget {
  const BookmarkSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listBookmarks = ref.watch(
      bookmarkPageProvider.select((s) => s.listBookmarks),
    );

    if (listBookmarks == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listBookmarks.isEmpty) {
      return const BookmarkEmptyState(
        message: 'There is no bookmark ayah yet',
      );
    }

    return ListView.builder(
      itemCount: listBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = listBookmarks[index];
        return BookmarkListItem(
          iconAssetPath: StoredIcon.iconBookmark.path,
          surahName: bookmark.surahName,
          subtitleText: 'Page ${bookmark.page}',
          trailingText: bookmark.createdAtFormatted,
          onTap: () async {
            final onPopParam = await Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: SuratPageV3(
                  param: SuratPageV3Param(
                    startPageInIndex: bookmark.page - 1,
                  ),
                ),
              ),
            );

            if (onPopParam is SuratPageV3OnPopParam) {
              await _refreshAfterPop(ref, onPopParam);
            }
          },
        );
      },
    );
  }

  Future<void> _refreshAfterPop(
    WidgetRef ref,
    SuratPageV3OnPopParam param,
  ) async {
    final notifier = ref.read(bookmarkPageProvider.notifier);
    final connectivityStatus = ref.read(internetConnectionStatusProvider);

    if (!param.isBookmarkChanged && param.isFavoriteAyahChanged) {
      await notifier.initFavoriteAyahSection();
    } else if (param.isBookmarkChanged && !param.isFavoriteAyahChanged) {
      await notifier.initBookmarkSection(
        connectivityStatus: connectivityStatus,
      );
    } else {
      await notifier.initStateNotifier(
        connectivityStatus: connectivityStatus,
      );
    }
  }
}
