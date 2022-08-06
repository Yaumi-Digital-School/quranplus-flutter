import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurantafsir_flutter/pages/data.dart';
import 'package:http/http.dart' as http;

const String downloadUrl =
    'https://firebasestorage.googleapis.com/v0/b/qurantafsir-63d22.appspot.com/o/test.json.zip?alt=media&token=cd2c2995-83ea-4e14-8d75-fd4a93e70cdf';

class MyAppTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _dir;
  late String fileName;
  late String text;

  @override
  void initState() {
    super.initState();
    fileName = testJsonName;
    text = 'tekan tombol untuk mendownload file';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.style),
        onPressed: () async {
          setState(() {
            text = 'lagi loading';
          });

          await _downloadAssets('test');

          text = await _getText();

          setState(() {});
        },
      ),
      body: Center(child: Text(text)),
    );
  }

  Future<String> _getText() async {
    final File file = _getLocalJsonFile(testJsonName, _dir!);
    final String content = await file.readAsString();
    final Map<String, dynamic> contentToJson = json.decode(content);

    return contentToJson['text'];
  }

  File _getLocalJsonFile(String name, String dir) => File('$dir/$name');

  Future<void> _downloadAssets(String name) async {
    _dir ??= (await getApplicationDocumentsDirectory()).path;

    if (!await _hasToDownloadAssets(name, _dir!)) {
      return;
    }
    var zippedFile = await _downloadFile(downloadUrl, '$name.zip', _dir!);

    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);

    for (var file in archive) {
      var filename = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(filename);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  Future<bool> _hasToDownloadAssets(String name, String dir) async {
    var file = File('$dir/$name.zip');
    return !(await file.exists());
  }

  Future<File> _downloadFile(String url, String filename, String dir) async {
    var req = await http.Client().get(Uri.parse(url));
    var file = File('$dir/$filename');
    return file.writeAsBytes(req.bodyBytes);
  }
}
