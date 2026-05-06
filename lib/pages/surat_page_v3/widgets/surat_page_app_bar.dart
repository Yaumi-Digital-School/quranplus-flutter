import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/app_icons.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';

class SuratPageAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const SuratPageAppBar({
    super.key,
    required this.onTapBack,
    required this.onTapPlayRecitation,
    required this.onTapOpenSettings,
  });

  final VoidCallback onTapBack;
  final VoidCallback onTapPlayRecitation;
  final VoidCallback onTapOpenSettings;

  @override
  Size get preferredSize => const Size.fromHeight(54.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(suratPageNavigationProvider);
    final contentState = ref.watch(suratPageContentProvider);
    final bookmarkState = ref.watch(suratPageBookmarkProvider);
    final bookmarkNotifier = ref.read(suratPageBookmarkProvider.notifier);
    final contentNotifier = ref.read(suratPageContentProvider.notifier);
    final connectivityStatus = ref.watch(internetConnectionStatusProvider);

    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
        onPressed: onTapBack,
      ),
      automaticallyImplyLeading: false,
      elevation: 2.5,
      foregroundColor: Theme.of(context).colorScheme.primary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            navState.visibleSuratName,
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          Row(
            children: <Widget>[
              Text(
                'Page ${navState.currentPage}',
                style: QPTextStyle.getDescription2Regular(context),
              ),
              Text(
                ', Juz ${navState.visibleJuzNumber}',
                style: QPTextStyle.getDescription2Regular(context),
              ),
            ],
          ),
        ],
      ),

      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: onTapPlayRecitation,
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        bookmarkState.visibleIconBookmark
            ? IconButton(
                icon: const Icon(Icons.bookmark_outlined),
                onPressed: () => bookmarkNotifier.deleteBookmark(
                  navState.currentPage,
                  connectivityStatus,
                ),
              )
            : IconButton(
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () => bookmarkNotifier.insertBookmark(
                  navState.visibleSuratName,
                  navState.currentPage,
                  connectivityStatus,
                ),
              ),
        IconButton(
          icon: const Icon(CustomIcons.book),
          onPressed: () => contentNotifier.setIsInFullPage(
            !contentState.readingSettings!.isInFullPage,
          ),
        ),
        IconButton(
          icon: const Icon(CustomIcons.sliders),
          onPressed: onTapOpenSettings,
        ),
      ],
    );
  }
}
