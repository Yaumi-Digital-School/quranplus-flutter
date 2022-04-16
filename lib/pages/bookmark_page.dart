// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, unused_element, unused_local_variable, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/pages/surat_page.dart';

import 'package:qurantafsir_flutter/shared/core/database/dbhelper.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({ Key? key }) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Surat> listBookmark = [];
  List<dynamic> listayatID = [];
  DbHelper db = DbHelper();
  
  @override
  void initState() {
    //menjalankan fungsi getallbookmark saat pertama kali dimuat
    _getAllBookmark();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(54.0),
          child: AppBar(
            elevation: 2.5,
            foregroundColor: Colors.black,
            title: Text("Bookmark"),
            backgroundColor: backgroundColor,
          ),
        ),
        body: ListView.builder(
            itemCount: listBookmark.length,
            itemBuilder: (context, index) {
              return _buildListBookmark(context, listayatID[index], index, listBookmark[index]);
            }),
    );
  }

  Widget _buildListBookmark(BuildContext context, listayatID, index, Surat bookmark) {
    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 8.0 ),
      child: ListTile(
        minLeadingWidth: 20,
                leading: Container(
          alignment: Alignment.center,
          height: 34,
          width: 30,
          decoration: const BoxDecoration(
              // shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    offset: Offset(1.0, 2.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0)
              ],
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            listayatID.toString(),
            style: bodyMedium3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        title: Text(
          bookmark.nameLatin,
          style: bodyMedium3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              bookmark.suratNameTranslation,
              style: caption1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              " ( ${bookmark.numberOfAyah} ayat )",
              style: caption1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: 
        FittedBox(
          fit: BoxFit.fill,
          child: Row(
            children: [
              // button hapus
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  //membuat dialog konfirmasi hapus
                  AlertDialog hapus = AlertDialog(
                    title: Text("Information"),
                    content: Container(
                      height: 100, 
                      child: Column(
                        children: [
                          Text(
                            "Yakin ingin Menghapus Data berikut ? \n Surat : ${bookmark.nameLatin} \n Ayat : $listayatID"
                          )
                        ],
                      ),
                    ),
                    //terdapat 2 button.
                    //jika ya maka jalankan _deleteBookmark() dan tutup dialog
                    //jika tidak maka tutup dialog
                    actions: [
                      TextButton(
                        onPressed: (){
                          _deleteBookmark(bookmark.number, listayatID, index);
                          Navigator.pop(context);
                        }, 
                        child: Text("Ya")
                      ), 
                      TextButton(
                        child: Text('Tidak'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                  showDialog(context: context, builder: (context) => hapus);
                }, 
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuratPage(surat: bookmark);
          }));
        },
      ),
    );
  }

  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  //mengambil semua data Bookmarks
  Future<void> _getAllBookmark() async {
    //list menampung data dari database
    var list = await db.getAllBookmark();

    List<Bookmarks> listbook = [];
    Map<String, dynamic> map = await json.decode(await getJson());
    List<dynamic> surat = map['surat'];

    //ada perubahanan state
    setState(() {
      //hapus data pada listBookmark
      listBookmark.clear();

      list!.forEach((bookmark) {
        listbook.add(Bookmarks.fromMap(bookmark));
      });

      surat.forEach((surat) {
        listbook.forEach((bookmark) {
          if (surat['number'] == bookmark.suratid) {
            listBookmark.add(Surat.fromJson(surat));
            listayatID.add(bookmark.ayatid);
          }
        });
      });
    });
  }

  //menghapus data Bookmark
  Future<void> _deleteBookmark(suratID, ayatID, int position) async {
    await db.deleteBookmark(suratID, ayatID);
    setState(() {
      listBookmark.removeAt(position);
    });
  }
}