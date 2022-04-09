// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, unused_element, unused_local_variable, sized_box_for_whitespace

import 'package:flutter/material.dart';
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
  List<Bookmarks> listBookmark = [];
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
              return _buildListBookmark(context, index, listBookmark[index]);
            }),
    );
  }

  Widget _buildListBookmark(BuildContext context, index, Bookmarks bookmark) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20
      ),
      child: ListTile(
        leading: Icon(
          Icons.person, 
          size: 50,
        ),
        title: Text(
          '${bookmark.id}'
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8, 
              ),
              child: Text("Surat Id: ${bookmark.suratid}"),
            ), 
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: Text("Ayat Id: ${bookmark.ayatid}"),
            )
          ],
        ),
        trailing: 
        FittedBox(
          fit: BoxFit.fill,
          child: Row(
            children: [
              // button edit 
              IconButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return SuratPage(surat: bookmark.suratid);
                  // }));
                },
                icon: Icon(Icons.remove_red_eye)
              ),
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
                            "Yakin ingin Menghapus Data ${bookmark.id}"
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
                          _deleteBookmark(bookmark, index);
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
      ),
    );
  }

  //mengambil semua data Bookmarks
  Future<void> _getAllBookmark() async {
    //list menampung data dari database
    var list = await db.getAllBookmark();

    //ada perubahanan state
    setState(() {
      //hapus data pada listBookmark
      listBookmark.clear();

      //lakukan perulangan pada variabel list
      list!.forEach((bookmark) {
        
        //masukan data ke listBookmark
        listBookmark.add(Bookmarks.fromMap(bookmark));
      });
    });
  }

  //menghapus data Bookmark
  Future<void> _deleteBookmark(Bookmarks bookmark, int position) async {
    await db.deleteBookmark(bookmark.id!);
    setState(() {
      listBookmark.removeAt(position);
    });
  }
}