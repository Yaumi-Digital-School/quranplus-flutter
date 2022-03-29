import 'package:flutter/material.dart';

class SuratPage extends StatelessWidget {
  const SuratPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Al-Fatihah"),
        actions: const [
          Icon(Icons.settings)
        ],
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