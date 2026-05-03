import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/widgets/bookmark_section.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/widgets/favorite_section.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';

class BookmarkPageV2 extends ConsumerStatefulWidget {
  const BookmarkPageV2({super.key});

  @override
  ConsumerState<BookmarkPageV2> createState() => _BookmarkPageV2State();
}

class _BookmarkPageV2State extends ConsumerState<BookmarkPageV2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final connectivityStatus = ref.read(internetConnectionStatusProvider);
      await ref
          .read(bookmarkPageProvider.notifier)
          .initStateNotifier(connectivityStatus: connectivityStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final navigationBar =
            mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
        navigationBar.onTap!(0);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              elevation: 0.7,
              foregroundColor: Theme.of(context).colorScheme.primary,
              centerTitle: true,
              title: const Text("Bookmark", style: TextStyle(fontSize: 16)),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              automaticallyImplyLeading: false,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 7),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.darkModeHeavy,
                      light: QPColors.whiteMassive,
                      brown: QPColors.brownModeSoft,
                      context: context,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(4.0),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    unselectedLabelColor: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteFair,
                      light: QPColors.brandFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                    labelColor: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteMassive,
                      light: QPColors.whiteMassive,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                    indicator: BoxDecoration(
                      color: QPColors.getColorBasedTheme(
                        dark: QPColors.blackFair,
                        light: QPColors.brandFair,
                        brown: QPColors.brownModeHeavy,
                        context: context,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    tabs: const <Widget>[
                      Tab(text: 'Bookmark'),
                      Tab(text: 'Favorite'),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                const Expanded(
                  child: TabBarView(
                    children: <Widget>[BookmarkSection(), FavoriteSection()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
