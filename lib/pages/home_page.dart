import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurantafsir_flutter/pages/login_page.dart';
import 'package:qurantafsir_flutter/pages/sidebar_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          elevation: 2.5,
          centerTitle: false,
          foregroundColor: primary500,
          title: Transform.translate(
            offset: const Offset(8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 65,
                  height: 24,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                    'images/logo.png',
                  ))),
                ),
                // SizedBox(
                //   height: 24.0,
                //   width: 80.0,
                //   child: Container(
                //     decoration: const BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.all(
                //           Radius.circular(24.0),
                //         ),
                //         boxShadow: [
                //           BoxShadow(
                //               color: Color.fromRGBO(0, 0, 0, 0.1),
                //               offset: Offset(1.0, 2.0),
                //               blurRadius: 5.0,
                //               spreadRadius: 1.0)
                //         ]),
                //     child: Stack(
                //       children: <Widget>[
                //         Center(
                //           child: Text("Sign in",
                //               style: buttonMedium2.copyWith(color: primary500)),
                //         ),
                //         SizedBox.expand(
                //           child: Material(
                //             type: MaterialType.transparency,
                //             child: InkWell(onTap: () {
                //               Navigator.push(context,
                //                   MaterialPageRoute(builder: (context) {
                //                 return const LoginPage();
                //               }));
                //             }),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          backgroundColor: backgroundColor,
        ),
      ),
      body: const ListSurat(),
      // drawer: const SideBarPage(),
    );
  }
}

class ListSurat extends StatefulWidget {
  const ListSurat({Key? key}) : super(key: key);

  @override
  State<ListSurat> createState() => _ListSuratState();
}

class _ListSuratState extends State<ListSurat> {
  List<Surat> foundSurat = [];
  List<Surat> listSurat = [];
  List<Surat> results = [];

  @override
  initState() {
    _getAllSurat(results);
    foundSurat = listSurat;
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      results = listSurat;
    } else {
      results = listSurat
              .where((user) => 
                user.nameLatin.toLowerCase().contains(enteredKeyword.toLowerCase())
              ).toList();
    }

    // refresh UI
    setState(() {
      foundSurat = results;
      // _getAllSurat(results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          TextField(
            onChanged: (value) => _runFilter(value),
            decoration: const InputDecoration(
                labelText: 'Search', suffixIcon: Icon(Icons.search)),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: foundSurat.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: foundSurat.length,
                itemBuilder: (context, index) {
                  return _buildListSurat(context, foundSurat[index]);
                },
            )
            : FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 2000)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Text(
                    'surat tidak ada',
                    style: TextStyle(fontSize: 24),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          )
        ],
      ),
    );
    // return FutureBuilder<String>(
    //   future:
    //       DefaultAssetBundle.of(context).loadString(AppConstants.jsonSurat),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       final List<Surat> surats =
    //           listSurat;
    //       return ListView.builder(
    //         shrinkWrap: true,
    //         itemCount: surats.length,
    //         itemBuilder: (context, index) {
    //           return _buildListSurat(context, surats[index]);
    //         },
    //       );
    //     } else {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //   });
  }

  Widget _buildListSurat(BuildContext context, Surat surat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            surat.number,
            style: bodyMedium3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        title: Text(
          surat.nameLatin,
          style: bodyMedium2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              surat.suratNameTranslation,
              style: caption1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "(${surat.numberOfAyah} ayat)",
              style: caption1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
        trailing:
            Text(surat.name, style: suratFontStyle, textAlign: TextAlign.right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SuratPage(surat: surat);
          }));
        },
      ),
    );
  }


  Future<String> getJson() {
    return rootBundle.loadString('data/quran.json');
  }

  //mengambil semua data Bookmarks
  Future<void> _getAllSurat(results) async {
    
    Map<String, dynamic> map = await json.decode(await getJson());
    List<dynamic> surat = map['surat'];

    //ada perubahanan state
    setState(() {
      //hapus data pada listSurat
      listSurat.clear();
      if(results.isEmpty) {
        for(var surat in surat) {
          listSurat.add(Surat.fromJson(surat));
        }
      } else {
        listSurat = results;
      }
    });
  }
}
