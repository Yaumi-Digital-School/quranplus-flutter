import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_view_model.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_v2.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v2/surat_page_v2.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

class BookmarkPageV2 extends StatefulWidget {
  const BookmarkPageV2({Key? key}) : super(key: key);

  @override
  _BookmarkPageV2State createState() => _BookmarkPageV2State();
}

class _BookmarkPageV2State extends State<BookmarkPageV2> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return ViewModelConnector<BookmarkPageViewModel, BookmarkPageState>(
      viewModelProvider:
          StateNotifierProvider<BookmarkPageViewModel, BookmarkPageState>(
        (ref) {
          return BookmarkPageViewModel();
        },
      ),
      onViewModelReady: (viewModel) async => await viewModel.initViewModel(),
      builder: (
        BuildContext context,
        BookmarkPageState state,
        BookmarkPageViewModel viewModel,
        _,
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
                elevation: 2.5,
                foregroundColor: Colors.black,
                title: Text("Bookmark"),
                backgroundColor: backgroundColor,
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
                        color: neutral200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: neutral600,
                            blurRadius: 7.0,
                            spreadRadius: 0.1,
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
                        if (state.listBookmarks!.isNotEmpty) ... [
                            ListView.builder(
                                itemCount: state.listBookmarks!.length,
                                itemBuilder: (context, index) {
                                  return _buildListBookmark(
                                    context: context,
                                    bookmark: state.listBookmarks![index],
                                    viewModel: viewModel,
                                  );
                                }),
                        ] else ... [
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
                                          spreadRadius: 3,
                                          blurRadius: 7,
                                          offset: Offset(0, 1),
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
                                        return HomePageV2();
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
    required BookmarkPageViewModel viewModel,
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
          "Surat ${bookmark.namaSurat.toString()}",
          style: bodyMedium3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              "Page ${bookmark.page.toString()}, ",
              style: caption1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Juz ${bookmark.juz.toString()}",
              style: caption1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text(bookmark.page.toString())],
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
            viewModel.initViewModel();
          }
        },
      ),
    );
  }
}
