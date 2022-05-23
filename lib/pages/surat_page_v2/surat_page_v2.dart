import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/bookmark_page.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_v2.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v2/surat_page_view_model.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

class SuratPageV2 extends StatelessWidget {
  SuratPageV2({
    Key? key,
    required this.surat,
    this.bookmarks,
  }) : super(key: key);

  Surat surat;
  Bookmarks? bookmarks;

  @override
  Widget build(BuildContext context) {
    return ViewModelConnector<SuratPageViewModel, SuratPageState>(
      viewModelProvider:
          StateNotifierProvider<SuratPageViewModel, SuratPageState>(
        (ref) {
          return SuratPageViewModel(
            surat: surat,
            bookmarks: bookmarks,
          );
        },
      ),
      onViewModelReady: (viewModel) => viewModel.initViewModel(),
      builder: (
        BuildContext context,
        SuratPageState state,
        SuratPageViewModel viewModel,
        _,
      ) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              elevation: 2.5,
              foregroundColor: Colors.black,
              title: Text("Surat ${surat.nameLatin}"),
              backgroundColor: backgroundColor,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAyatRow(
              context: context,
              viewModel: viewModel,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAyatRow({
    required BuildContext context,
    required SuratPageViewModel viewModel,
  }) {
    Timer _timer = Timer(const Duration(milliseconds: 200), () {});
    final suratTaubah = surat.number != "9";
    var bookmarked = false;

    return ListView(
      children: [
        Visibility(
          visible: suratTaubah,
          child: Container(
            width: 162,
            height: 85,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
              'images/bismillah.png',
            ))),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: surat.ayats.text.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onPanCancel: () => _timer.cancel(),
              onPanDown: (_) => {
                _timer = Timer(
                  const Duration(milliseconds: 200),
                  () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return SizedBox(
                            height: 100,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Center(
                                  child:
                                      Text("${surat.nameLatin} : ${index + 1}"),
                                ),
                                const SizedBox(
                                  height: 24.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        bookmarked = !bookmarked;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                            'images/icon_bookmark_outlined.png',
                                          ))),
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        // Text("Bookmark", style: bodyMedium2)
                                        FutureBuilder(
                                          future: viewModel.checkBookmark(
                                              surat.number, index + 1),
                                          builder: (context, boolean) {
                                            if (boolean.data == true) {
                                              return TextButton(
                                                  child: const Text(
                                                    'Sudah Bookmark',
                                                    style: TextStyle(
                                                        color: neutral900,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  onPressed: () {
                                                    viewModel.deleteBookmark(
                                                        surat.number,
                                                        index + 1);
                                                    Navigator.pop(context);
                                                  });
                                            } else {
                                              return TextButton(
                                                child: const Text(
                                                  'Bookmark',
                                                  style: TextStyle(
                                                      color: neutral900,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                onPressed: () async {
                                                  viewModel.insertBookmark(
                                                      surat.number, index + 1);
                                                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BookmarkPageV2())).then((value) {
                                                    viewModel.onGoBack(context);
                                                  });
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                      },
                    );
                  },
                )
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FutureBuilder<bool>(
                    future: viewModel.checkBookmark(surat.number, index + 1),
                    builder: (context, boolean) {
                      if (boolean.hasData) {
                        var newBool = boolean.data;
                        return Visibility(
                          visible: newBool!,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'images/icon_bookmark.png',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Visibility(
                          visible: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'images/icon_bookmark.png',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    surat.ayats.text[index],
                    style: ayatFontStyle,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "${index + 1}. ${surat.translations.text[index]}",
                      style: bodyRegular3,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
