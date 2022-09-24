import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

class BookmarkPageV2 extends StatefulWidget {
  const BookmarkPageV2({Key? key}) : super(key: key);

  @override
  _BookmarkPageV2State createState() => _BookmarkPageV2State();
}

class _BookmarkPageV2State extends State<BookmarkPageV2> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return StateNotifierConnector<BookmarkPageStateNotifier, BookmarkPageState>(
      stateNotifierProvider:
          StateNotifierProvider<BookmarkPageStateNotifier, BookmarkPageState>(
        (ref) {
          return BookmarkPageStateNotifier(
            isLoggedIn: ref.watch(authenticationService).isLoggedIn,
            bookmarksService: ref.watch(bookmarksService),
          );
        },
      ),
      onStateNotifierReady: (notifier) async {
        final ConnectivityResult connectivity =
            await Connectivity().checkConnectivity();

        await notifier.initStateNotifier(
          connectivityResult: connectivity,
        );
      },
      builder: (
        BuildContext context,
        BookmarkPageState state,
        BookmarkPageStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (state.listBookmarks == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(54.0),
              child: AppBar(
                elevation: 0.7,
                foregroundColor: Colors.black,
                centerTitle: true,
                title: const Text(
                  "Bookmark",
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: backgroundColor,
                leading: IconButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return const MainPage();
                  })),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 7,
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: neutral100,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: neutral300,
                            blurRadius: 9.0,
                            spreadRadius: 0.9,
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TabBar(
                        unselectedLabelColor: primary500,
                        indicator: BoxDecoration(
                            color: primary500,
                            borderRadius: BorderRadius.circular(20)),
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
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        if (state.listBookmarks!.isNotEmpty) ...[
                          ListView.builder(
                              itemCount: state.listBookmarks!.length,
                              itemBuilder: (context, index) {
                                return _buildListBookmark(
                                  context: context,
                                  bookmark: state.listBookmarks![index],
                                  notifier: notifier,
                                );
                              }),
                        ] else ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: 200,
                                height: 200,
                                decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                  'images/empty_state.png',
                                ))),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Text(
                                'Ayah not found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: semiBold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'There is no bookmark ayah yet',
                                style: TextStyle(
                                  fontWeight: regular,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 40,
                                width: deviceWidth * 0.8,
                                decoration: const BoxDecoration(
                                  color: neutral100,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: neutral300,
                                      blurRadius: 9,
                                    )
                                  ],
                                ),
                                child: TextButton(
                                  child: const Text(
                                    'Start Reading',
                                    style: TextStyle(
                                        color: primary500, fontSize: 17),
                                  ),
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MainPage();
                                  })),
                                ),
                              ),
                            ],
                          )
                        ],
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              width: 200,
                              height: 200,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                'images/coming_soon.png',
                              ))),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Text(
                              'Coming Soon!',
                              style: TextStyle(
                                color: neutral700,
                                fontSize: 20,
                                fontWeight: semiBold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'This feature is still under development',
                              style: TextStyle(
                                fontWeight: regular,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
    );
  }

  Widget _buildListBookmark({
    required BuildContext context,
    required Bookmarks bookmark,
    required BookmarkPageStateNotifier notifier,
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
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                'images/icon_bookmark.png',
              ))),
            ),
          ],
        ),
        title: Text(
          "Surat ${bookmark.surahName}",
          style: bodyMedium3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              "Page ${bookmark.page.toString()}",
              style: caption1,
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
              style: caption1,
            ),
          ],
        ),
        onTap: () async {
          var isBookmarkChanged = await Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: SuratPageV3(
                startPageInIndex: bookmark.page - 1,
              ),
            ),
          );

          if (isBookmarkChanged is bool && isBookmarkChanged) {
            final ConnectivityResult connectivityResult =
                await Connectivity().checkConnectivity();
            await notifier.initStateNotifier(
                connectivityResult: connectivityResult);
          }
        },
      ),
    );
  }
}
