import 'dart:ffi';

import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbBookmarks {
  static final DbBookmarks _instance = DbBookmarks._internal();
  static Database? _database;

  //inisialisasi beberapa variabel yang dibutuhkan
  final String tableName = 'bookmarks';
  final String columnId = 'id';
  final String columnNamaSurat = 'namaSurat';
  final String columnJuz = 'juz';
  final String columnPage = 'page';

  DbBookmarks._internal();
  factory DbBookmarks() => _instance;

  //cek apakah database ada
  Future<Database?> get _db  async {
    // _database.delete(tableName);
    if (_database != null) {
      return _database;
    }
    _database = await _initDb();
    return _database;
  }

  Future<Database?> _initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'bookmarks.db');
    print("database path" + path);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _deleteDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'bookmarks.db');

    databaseFactory.deleteDatabase(path);
  }

  //membuat tabel dan field-fieldnya
  Future<void> _onCreate(Database db, int version) async {
     var sql = "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnNamaSurat TEXT, $columnJuz TEXT, $columnPage TEXT)";
     await db.execute(sql);
  }

  //insert ke database
  Future<int?> saveBookmark(Bookmarks bookmark) async {
    var dbClient = await _db;
    return await dbClient!.insert(tableName, bookmark.toMap());
  }

  //read database
  Future<List?> getAllBookmark() async {
    var dbClient = await _db;
    var result = await dbClient!.query(tableName, columns: [
      columnId,
      columnNamaSurat,
      columnJuz,
      columnPage
    ]);

    return result.toList();
  }

  // //update database
  // Future<int?> updateBookmark(Bookmarks bookmark) async {
  //   var dbClient = await _db;
  //   return await dbClient!.update(tableName, bookmark.toMap(), where: '$columnAyatid = ?', whereArgs: [bookmark.ayatid]);
  // }

  //hapus database
  Future<int?> deleteBookmark(startPage) async {
    var dbClient = await _db;
    return await dbClient!.delete(tableName, where: '$columnPage = ?', whereArgs: [startPage]);
  }

  //cek 1 data didatabase
  // Future<bool?> isBookmark(surat, ayat) async {
  //   var dbclient = await _db;
  //   List<Map> maps = await dbclient!.query(tableName,
  //       columns: [
  //         columnId,
  //         columnSuratid,
  //         columnAyatid,
  //       ],
  //       where: '$columnSuratid = ? and $columnAyatid = ?',
  //       whereArgs: [surat, ayat]);
  //   if (maps.isNotEmpty) {
  //     return true;
  //   }
  //   return false;
  // }
}