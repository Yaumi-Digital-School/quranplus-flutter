import 'package:flutter/material.dart';
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
                      ),
                    ),
                  ),
                ),
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(AppConstants.jsonSurat),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Surat> surats = quranFromJson(snapshot.requireData).surat;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: surats.length,
            itemBuilder: (context, index) {
              return _buildListSurat(context, surats[index]);
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
                color: Color.fromRGBO(
                  0,
                  0,
                  0,
                  0.1,
                ),
                offset: Offset(1.0, 2.0),
                blurRadius: 5.0,
                spreadRadius: 1.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
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
            ),
          ],
        ),
        trailing:
            Text(surat.name, style: suratFontStyle, textAlign: TextAlign.right),
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return SuratPageV3(surat: surat);
          // }));
        },
      ),
    );
  }
}
