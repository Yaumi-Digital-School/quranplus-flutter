import 'dart:ffi';

import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DbBookmarks {
  static final DbBookmarks _instance = DbBookmarks._internal();
  static Database? _database;

  final int _currentVersion = 2;

  //inisialisasi beberapa variabel yang dibutuhkan
  final String tableName = 'bookmarks';
  final String columnId = 'id';
  final String columnPage = 'page';

  // V1
  final String columnNamaSurat = 'namaSurat';
  final String columnJuz = 'juz';

  // V2
  final String columnSurahName = 'surahName';
  final String columnCreatedAt = 'createdAt';

  DbBookmarks._internal();
  factory DbBookmarks() => _instance;

  //cek apakah database ada
  Future<Database?> get _db async {
    // _database.delete(tableName);
    if (_database != null) {
      return _database;
    }
    _database = await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'bookmarks.db');
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        switch (oldVersion) {
          case 1:
            await db.transaction((txn) async {
              await txn.execute(
                  'CREATE TABLE temp_$tableName($columnId INTEGER PRIMARY KEY, $columnSurahName TEXT, $columnPage INTEGER, $columnCreatedAt TEXT)');
              await txn.execute('''
                INSERT INTO temp_$tableName($columnSurahName, $columnPage)
                SELECT $columnNamaSurat, $columnPage
                FROM $tableName
              ''');
              await txn.execute('DROP TABLE $tableName');
              await txn
                  .execute('ALTER TABLE temp_$tableName RENAME TO $tableName');
            });
            break;
          default:
            break;
        }
      },
    );
  }

  Future<void> _deleteDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'bookmarks.db');

    databaseFactory.deleteDatabase(path);
  }

  //membuat tabel dan field-fieldnya
  Future<void> _onCreate(Database db, int version) async {
    var sql =
        "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnSurahName TEXT, $columnPage INTEGER, $columnCreatedAt TEXT)";
    await db.execute(sql);
  }

  Future<void> clearTable() async {
    final Database db = await _db ?? await _initDb();
    final String sql = 'DELETE FROM $tableName';
    await db.execute(sql);
  }

  Future<void> bulkCreateBookmarks(List<Bookmarks> bookmarks) async {
    final Database db = await _db ?? await _initDb();
    await db.transaction((txn) async {
      for (Bookmarks bookmark in bookmarks) {
        await txn.insert(tableName, bookmark.toMapAfterMergeToServer());
      }
    });
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
      columnSurahName,
      columnPage,
      columnCreatedAt,
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
    return await dbClient!
        .delete(tableName, where: '$columnPage = ?', whereArgs: [startPage]);
  }

  Future<bool?> oneBookmark(startPage) async {
    var dbclient = await _db;
    List<Map> maps = await dbclient!.query(tableName,
        columns: [
          columnId,
          columnSurahName,
          columnPage,
          columnCreatedAt,
        ],
        where: '$columnPage = ?',
        whereArgs: [startPage]);
    if (maps.isNotEmpty) {
      return true;
    }
    return false;
  }
}
