import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';

class HomePageV2 extends StatelessWidget {
  const HomePageV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.5,
          centerTitle: false,
          foregroundColor: primary500,
          title: Transform.translate(
            offset: const Offset(8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 24,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                    'images/logo.png',
                  ))),
                ),
              ],
            ),
          ),
          backgroundColor: backgroundColor,
        ),
      ),
      body: const ListSuratByJuz(),
    );
  }
}

class ListSuratByJuz extends StatefulWidget {
  const ListSuratByJuz({Key? key}) : super(key: key);

  @override
  State<ListSuratByJuz> createState() => _ListSuratByJuzState();
}

class _ListSuratByJuzState extends State<ListSuratByJuz> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(AppConstants.jsonJuz),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<JuzElement> juzs = juzFromJson(snapshot.requireData).juz;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: juzs.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Container(
                      height: 42,
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(color: neutral200),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        juzs[index].name,
                        textAlign: TextAlign.start,
                        style: bodyRegular1,
                      ),
                    ),
                    _buildListSuratByJuz(context, juzs[index])
                  ],
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildListSuratByJuz(BuildContext context, JuzElement juz) {
    final List<SuratByJuz> surats = juz.surat;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: surats.length,
        itemBuilder: (context, index) {
          return ListTile(
            minLeadingWidth: 20,
            leading: Container(
              alignment: Alignment.center,
              height: 34,
              width: 30,
              decoration: const BoxDecoration(
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
                surats[index].number,
                style: numberStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            title: Text(
              surats[index].nameLatin,
              style: bodyMedium2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Page ${surats[index].startPage}, Ayat ${surats[index].startAyat}",
              style: bodyLight3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              surats[index].name,
              style: suratFontStyle,
              textAlign: TextAlign.right,
            ),
            onTap: () {
              int page = surats[index].startPageToInt;
              int startPageInIndexValue = page - 1;

              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: SuratPageV3(
                    startPageInIndex: startPageInIndexValue,
                    firstPagePointerIndex: surats[index].hashKey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
