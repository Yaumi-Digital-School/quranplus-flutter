import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/widgets/bookmark_empty_state.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/widgets/bookmark_list_item.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';

class FavoriteSection extends ConsumerWidget {
  const FavoriteSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listFavoriteAyah = ref.watch(
      bookmarkPageProvider.select((s) => s.listFavoriteAyah),
    );

    if (listFavoriteAyah == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listFavoriteAyah.isEmpty) {
      return const BookmarkEmptyState(
        message: 'There is no favorite ayah yet',
      );
    }

    return ListView.builder(
      itemCount: listFavoriteAyah.length,
      itemBuilder: (context, index) {
        final favoriteAyah = listFavoriteAyah[index];
        return BookmarkListItem(
          iconAssetPath: StoredIcon.iconFavorite.path,
          surahName: favoriteAyah.surahName,
          subtitleText: 'Ayah ${favoriteAyah.ayahSurah}',
          onTap: () async {
            final onPopParam = await Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: SuratPageV3(
                  param: SuratPageV3Param(
                    startPageInIndex: favoriteAyah.page - 1,
                    firstPagePointerIndex: favoriteAyah.ayahHashCode,
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
