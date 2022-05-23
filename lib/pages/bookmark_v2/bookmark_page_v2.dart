import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_view_model.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v2/surat_page_v2.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';
import 'package:qurantafsir_flutter/shared/ui/view_model_connector.dart';

class BookmarkPageV2 extends StatefulWidget {
  const BookmarkPageV2({
    Key? key
  }) : super(key: key);

  @override
  _BookmarkPageV2State createState() => _BookmarkPageV2State();
}
class _BookmarkPageV2State extends State<BookmarkPageV2> {

  // late BookmarkPageViewModel viewM;

  // @override
  // void initState() {
  //   //menjalankan fungsi getallbookmark saat pertama kali dimuat
  //   viewM.getAllBookmark();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return ViewModelConnector<BookmarkPageViewModel, BookmarkPageState>(
      viewModelProvider: 
      StateNotifierProvider<BookmarkPageViewModel, BookmarkPageState>(
        (ref) {
          return BookmarkPageViewModel(

          );
        },
      ),
      onViewModelReady: (viewModel) => viewModel.initViewModel(),
      builder: (
        BuildContext context,
        BookmarkPageState state,
        BookmarkPageViewModel viewModel,
        _,
      ) {
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
                itemCount: viewModel.listBookmark.length,
                itemBuilder: (context, index) {
                  return _buildListBookmark(
                    context: context, 
                    listayatID: viewModel.listayatID[index], 
                    index: index, 
                    bookmark: viewModel.listBookmark[index],
                    viewModel: viewModel,
                  );
                }),
        );
      },
    );
  }

  Widget _buildListBookmark({
    required BuildContext context,
    required listayatID,
    index,
    required Surat bookmark,
    required BookmarkPageViewModel viewModel,
  }) {
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
                          viewModel.deleteBookmark(bookmark.number, listayatID, index);
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
            return SuratPageV2(surat: bookmark);
          }));
        },
      ),
    );
  }
}