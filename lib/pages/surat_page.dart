import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class SuratPage extends StatelessWidget {
  final Surat surat;

  const SuratPage({ Key? key, required this.surat }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          elevation: 2.5,
          // centerTitle: false,
          foregroundColor: Colors.black,
          title: Text(surat.nameLatin),
          backgroundColor: backgroundColor,
        ),
      ),
      body: const ListAyat(),
    );
  }
}

class ListAyat extends StatefulWidget {
  const ListAyat({ Key? key }) : super(key: key);

  @override
  State<ListAyat> createState() => _ListAyatState();
}

class _ListAyatState extends State<ListAyat> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}