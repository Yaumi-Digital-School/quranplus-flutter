import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_view_model.dart';
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
    return ViewModelConnector<BookmarkPageViewModel, BookmarkPageState>(
      viewModelProvider:
          StateNotifierProvider<BookmarkPageViewModel, BookmarkPageState>(
        (ref) {
          return BookmarkPageViewModel();
        },
      ),
      onViewModelReady: (viewModel) => viewModel.initViewModel(),
      builder: (
        BuildContext context,
        BookmarkPageState state,
        BookmarkPageViewModel viewModel,
        _,
      ) {
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
                        boxShadow: [
                          const BoxShadow(
                            color: neutral600,
                            blurRadius: 7.0,
                            spreadRadius: 0.1,
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TabBar(
                        indicator: BoxDecoration(
                            color: primary500,
                            borderRadius: BorderRadius.circular(20)),
                        tabs: <Widget>[
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
                        ListView.builder(
                            itemCount: viewModel.listBookmark.length,
                            itemBuilder: (context, index) {
                              return _buildListBookmark(
                                context: context,
                                bookmark: viewModel.listBookmark[index],
                                viewModel: viewModel,
                              );
                            }),
                        Container(
                          child: Text('Favorite'),
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
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuratPageV3(
              startPage: bookmark.page! - 1,
              namaSurat: bookmark.namaSurat.toString(),
              juz: bookmark.juz!,
            );
          }));
        },
      ),
    );
  }
}
