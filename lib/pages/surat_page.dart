import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class SuratPage extends StatelessWidget {
  DbLocal db = DbLocal();
  final Surat surat;
  Bookmarks? bookmark;

  SuratPage({Key? key, required this.surat, this.bookmark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: _buildAyatRow(context: context, surat: surat),
      ),
    );
  }

  Widget _buildAyatRow({required BuildContext context, required Surat surat}) {
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
                ),
              ),
            ),
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
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  },
                ),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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

  // Future<bool> checkBookmark(suratID, ayatID) async {
  //   var result = await db.isBookmark(suratID, ayatID);
  //   if (result == false) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  // Future<void> insertBookmark(suratID, ayatID) async {
  //   var result = await db.isBookmark(suratID, ayatID);

  //   // if (result == false) {
  //   //   await db.saveBookmark(Bookmarks(
  //   //     suratid: surat.number,
  //   //     ayatid: ayatID.toString(),
  //   //   ));
  //   // }
  // }

  //menghapus data Bookmark
  // Future<void> deleteBookmark(suratID, ayatID) async {
  //   await db.deleteBookmark(suratID, ayatID);
  // }
}
