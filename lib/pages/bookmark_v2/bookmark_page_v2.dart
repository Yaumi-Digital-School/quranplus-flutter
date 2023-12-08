import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

// TODO: we need to refactor this file into separate file
class BookmarkPageV2 extends StatelessWidget {
  const BookmarkPageV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final navigationBar =
            mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
        navigationBar.onTap!(0);

        return false;
      },
      child:
          StateNotifierConnector<BookmarkPageStateNotifier, BookmarkPageState>(
        stateNotifierProvider:
            StateNotifierProvider<BookmarkPageStateNotifier, BookmarkPageState>(
          (ref) {
            return BookmarkPageStateNotifier(
              isLoggedIn: ref.watch(authenticationService).isLoggedIn,
              bookmarksService: ref.watch(bookmarksService),
              favoriteAyahsService: ref.watch(favoriteAyahsService),
            );
          },
        ),
        onStateNotifierReady: (notifier, ref) async {
          final connectivityStatus =
              ref.watch(internetConnectionStatusProviders);

          await notifier.initStateNotifier(
            connectivityStatus: connectivityStatus,
          );
        },
        builder: (
          BuildContext context,
          BookmarkPageState state,
          BookmarkPageStateNotifier notifier,
          WidgetRef ref,
        ) {
          final connectivityStatus =
              ref.watch(internetConnectionStatusProviders);

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(54.0),
                child: AppBar(
                  elevation: 0.7,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  centerTitle: true,
                  title: const Text(
                    "Bookmark",
                    style: TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  automaticallyImplyLeading: false,
                ),
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 7,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: QPColors.getColorBasedTheme(
                          dark: QPColors.darkModeHeavy,
                          light: QPColors.whiteMassive,
                          brown: QPColors.brownModeSoft,
                          context: context,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        padding: const EdgeInsets.all(4.0),
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        tabs: const <Widget>[
                          Tab(
                            text: 'Bookmark',
                          ),
                          Tab(
                            text: 'Favorite',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          _buildBookmarkSection(
                            notifier: notifier,
                            state: state,
                            context: context,
                            connectivityStatus: connectivityStatus,
                          ),
                          _buildFavoriteSection(
                            notifier: notifier,
                            state: state,
                            context: context,
                            connectivityStatus: connectivityStatus,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteSection({
    required BookmarkPageState state,
    required BookmarkPageStateNotifier notifier,
    required BuildContext context,
    required ConnectivityStatus connectivityStatus,
  }) {
    if (state.listFavoriteAyah == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.listFavoriteAyah!.isNotEmpty) {
      return ListView.builder(
        itemCount: state.listFavoriteAyah!.length,
        itemBuilder: (context, index) {
          return _buildFavoritedAyah(
            context: context,
            favoriteAyah: state.listFavoriteAyah![index],
            notifier: notifier,
            connectivityStatus: connectivityStatus,
          );
        },
      );
    }

    return _buildEmptyState(
      message: 'There is no favorite ayah yet',
      context: context,
    );
  }

  Widget _buildBookmarkSection({
    required BookmarkPageState state,
    required BookmarkPageStateNotifier notifier,
    required BuildContext context,
    required ConnectivityStatus connectivityStatus,
  }) {
    if (state.listBookmarks == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.listBookmarks!.isNotEmpty) {
      return ListView.builder(
        itemCount: state.listBookmarks!.length,
        itemBuilder: (context, index) {
          return _buildListBookmark(
            context: context,
            bookmark: state.listBookmarks![index],
            notifier: notifier,
            connectivityStatus: connectivityStatus,
          );
        },
      );
    }

    return _buildEmptyState(
      message: 'There is no bookmark ayah yet',
      context: context,
    );
  }

  Widget _buildFavoritedAyah({
    required BuildContext context,
    required FavoriteAyahs favoriteAyah,
    required BookmarkPageStateNotifier notifier,
    required ConnectivityStatus connectivityStatus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        minLeadingWidth: 20,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    StoredIcon.iconFavorite.path,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          'Surat ${favoriteAyah.surahName}',
          style: QPTextStyle.getSubHeading3SemiBold(context),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              'Ayah ${favoriteAyah.ayahSurah.toString()}',
              style: QPTextStyle.getSubHeading4Regular(context).copyWith(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteRoot,
                  light: QPColors.whiteFair,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () async {
          var onPopParam = await Navigator.push(
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
            _onPopFromSurahPage(
              onPopParam,
              notifier,
              connectivityStatus,
            );
          }
        },
      ),
    );
  }

  String _getEmptyStateImageUrl(BuildContext context) {
    final mode = QPThemeData.getThemeModeBasedContext(context);
    switch (mode) {
      case QPThemeMode.brown:
        return ImagePath.emptyStateBrown;
      case QPThemeMode.dark:
        return ImagePath.emptyStateDark;
      default:
        return ImagePath.emptyStateLight;
    }
  }

  Widget _buildEmptyState({
    required String message,
    required BuildContext context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.darkModeHeavy,
                light: QPColors.whiteSoft,
                brown: QPColors.brownModeSoft,
                context: context,
              ),
            ),
            child: Image.asset(
              _getEmptyStateImageUrl(context),
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Text(
          'Ayah not found',
          style: QPTextStyle.getSubHeading2SemiBold(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          message,
          style: QPTextStyle.getSubHeading4Regular(context).copyWith(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.whiteRoot,
              light: QPColors.whiteFair,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const MainPage();
          })),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6.5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.blackHeavy,
                light: QPColors.whiteMassive,
                brown: QPColors.brownModeRoot,
                context: context,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.blackFair,
                  light: Colors.transparent,
                  brown: QPColors.brownModeHeavy,
                  context: context,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 0.9),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Start Reading",
                style: QPTextStyle.getButton1SemiBold(context).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.brandFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListBookmark({
    required BuildContext context,
    required Bookmarks bookmark,
    required BookmarkPageStateNotifier notifier,
    required ConnectivityStatus connectivityStatus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        minLeadingWidth: 20,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    StoredIcon.iconBookmark.path,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          "Surat ${bookmark.surahName}",
          style: QPTextStyle.getSubHeading3SemiBold(context),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              "Page ${bookmark.page.toString()}",
              style: QPTextStyle.getSubHeading4Regular(context).copyWith(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteRoot,
                  light: QPColors.whiteFair,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              bookmark.createdAtFormatted,
              textAlign: TextAlign.right,
              style: QPTextStyle.getSubHeading3Regular(context),
            ),
          ],
        ),
        onTap: () async {
          var onPopParam = await Navigator.push(
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
            _onPopFromSurahPage(
              onPopParam,
              notifier,
              connectivityStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _onPopFromSurahPage(
    SuratPageV3OnPopParam onPopParam,
    BookmarkPageStateNotifier notifier,
    ConnectivityStatus connectivityStatus,
  ) async {
    final bool bookmarkChanged = onPopParam.isBookmarkChanged;
    final bool favoriteAyahChanged = onPopParam.isFavoriteAyahChanged;

    if (!bookmarkChanged && favoriteAyahChanged) {
      await notifier.initFavoriteAyahSection();
    } else if (bookmarkChanged && !favoriteAyahChanged) {
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
