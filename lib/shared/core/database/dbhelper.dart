// // ignore_for_file: non_constant_identifier_names


// //dbhelper ini dibuat untuk
// //membuat database, membuat tabel, proses insert, read, update dan delete


// import 'dart:ffi';

// import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite/sqlite_api.dart';
// import 'package:path/path.dart';

// class DbHelper {
//   static final DbHelper _instance = DbHelper._internal();
//   static Database? _database;

//   //inisialisasi beberapa variabel yang dibutuhkan
//   final String tableName = 'bookmarks';
//   final String columnId = 'id';
//   final String columnSuratid = 'suratid';
//   final String columnAyatid = 'ayatid';

//   DbHelper._internal();
//   factory DbHelper() => _instance;

//   //cek apakah database ada
//   Future<Database?> get _db  async {
//     if (_database != null) {
//       _deleteDb();
//       return _database;
//     }
//     _database = await _initDb();
//     return _database;
//   }

//   Future<Database?> _initDb() async {
//     String databasePath = await getDatabasesPath();
//     String path = join(databasePath, 'bookmarks.db');

//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future<void> _deleteDb() async {
//     String databasePath = await getDatabasesPath();
//     String path = join(databasePath, 'bookmarks.db');

//     databaseFactory.deleteDatabase(path);
//   }

//   //membuat tabel dan field-fieldnya
//   Future<void> _onCreate(Database db, int version) async {
//      var sql = "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, "
//          "$columnSuratid TEXT,"
//          "$columnAyatid TEXT)";
//      await db.execute(sql);
//   }

//   //insert ke database
//   Future<int?> saveBookmark(Bookmarks bookmark) async {
//     var dbClient = await _db;
//     return await dbClient!.insert(tableName, bookmark.toMap());
//   }

//   //read database
//   Future<List?> getAllBookmark() async {
//     var dbClient = await _db;
//     var result = await dbClient!.query(tableName, columns: [
//       columnId,
//       columnSuratid,
//       columnAyatid
//     ]);

//     return result.toList();
//   }

//   //update database
//   // Future<int?> updateBookmark(Bookmarks bookmark) async {
//   //   var dbClient = await _db;
//   //   return await dbClient!.update(tableName, bookmark.toMap(), where: '$columnAyatid = ?', whereArgs: [bookmark.ayatid]);
//   // }

//   //hapus database
//   Future<int?> deleteBookmark(suratID, ayatID) async {
//     var dbClient = await _db;
//     return await dbClient!.delete(tableName, where: '$columnSuratid = ? and $columnAyatid = ?', whereArgs: [suratID, ayatID]);
//   }

//   //cek 1 data didatabase
//   Future<bool?> isBookmark(surat, ayat) async {
//     var dbclient = await _db;
//     List<Map> maps = await dbclient!.query(tableName,
//         columns: [
//           columnId,
//           columnSuratid,
//           columnAyatid,
//         ],
//         where: '$columnSuratid = ? and $columnAyatid = ?',
//         whereArgs: [surat, ayat]);
//     if (maps.isNotEmpty) {
//       return true;
//     }
//     return false;
//   }
// }