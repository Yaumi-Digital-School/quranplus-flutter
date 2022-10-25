import 'package:qurantafsir_flutter/shared/core/database/db_bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/database/migration.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbLocal {
  static final DbLocal _instance = DbLocal._internal();
  static Database? _database;
  static final DbMigration migration = DbMigration();

  final int _currentVersion = migration.migrationsCount;

  DbLocal._internal();
  factory DbLocal() => _instance;

  //cek apakah database ada
  Future<Database> get _db async {
    // _database.delete(${migration.tableName});
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'bookmarks.db');
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await migration.migrate(
          db,
          oldVersion: oldVersion,
        );
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
    await migration.migrate(db);
  }

  Future<void> clearTableBookmarks() async {
    final Database db = await _db;
    final String sql = 'DELETE FROM ${BookmarksTable.tableName}';
    await db.execute(sql);
  }

  Future<void> bulkCreateBookmarks(List<Bookmarks> bookmarks) async {
    final Database db = await _db;
    await db.transaction((txn) async {
      for (Bookmarks bookmark in bookmarks) {
        await txn.insert(
            BookmarksTable.tableName, bookmark.toMapAfterMergeToServer());
      }
    });
  }

  //insert ke database
  Future<int?> saveBookmark(Bookmarks bookmark) async {
    var dbClient = await _db;
    return await dbClient.insert(BookmarksTable.tableName, bookmark.toMap());
  }

  //read database
  Future<List?> getAllBookmark() async {
    var dbClient = await _db;
    var result = await dbClient.query(
      BookmarksTable.tableName,
      columns: [
        BookmarksTable.columnId,
        BookmarksTable.columnSurahName,
        BookmarksTable.columnPage,
        BookmarksTable.columnCreatedAt,
      ],
      orderBy: "datetime(${BookmarksTable.columnCreatedAt}) DESC",
    );

    return result.toList();
  }

  Future<int?> deleteBookmark(startPage) async {
    var dbClient = await _db;
    return await dbClient.delete(BookmarksTable.tableName,
        where: '${BookmarksTable.columnPage} = ?', whereArgs: [startPage]);
  }

  Future<bool?> oneBookmark(startPage) async {
    var dbClient = await _db;
    List<Map> maps = await dbClient.query(BookmarksTable.tableName,
        columns: [
          BookmarksTable.columnId,
          BookmarksTable.columnSurahName,
          BookmarksTable.columnPage,
          BookmarksTable.columnCreatedAt,
        ],
        where: '${BookmarksTable.columnPage} = ?',
        whereArgs: [startPage]);
    if (maps.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> clearTableFavoriteAyahs() async {
    final Database db = await _db;
    final String sql = 'DELETE FROM ${FavoriteAyahsTable.tableName}';
    await db.execute(sql);
  }

  Future<void> bulkCreateFavoriteAyahs(List<FavoriteAyahs> favorites) async {
    final Database db = await _db;
    await db.transaction((txn) async {
      for (FavoriteAyahs favorite in favorites) {
        await txn.insert(FavoriteAyahsTable.tableName, favorite.toMap());
      }
    });
  }

  Future<int> saveFavoriteAyahs(FavoriteAyahs favoriteAyahs) async {
    var dbClient = await _db;
    return await dbClient.insert(
      FavoriteAyahsTable.tableName,
      favoriteAyahs.toMap(),
    );
  }

  Future<List<FavoriteAyahs>> getAllFavoriteAyahs() async {
    var dbClient = await _db;
    List result = await dbClient.query(
      FavoriteAyahsTable.tableName,
      columns: [
        FavoriteAyahsTable.columnId,
        FavoriteAyahsTable.ayahSurah,
        FavoriteAyahsTable.page,
        FavoriteAyahsTable.createdAt,
        FavoriteAyahsTable.surahId,
        FavoriteAyahsTable.ayahHashCode,
      ],
    );

    List<FavoriteAyahs> list = <FavoriteAyahs>[];

    for (dynamic item in result) {
      list.add(FavoriteAyahs.fromMap(item));
    }

    return list;
  }

  Future<int?> deleteFavoriteAyahs(int ayahID) async {
    var dbClient = await _db;
    return await dbClient.delete(
      FavoriteAyahsTable.tableName,
      where: '${FavoriteAyahsTable.ayahHashCode} = ?',
      whereArgs: [ayahID],
    );
  }

  Future<bool?> checkFavoriteAyahs({
    required int surahId,
    required int ayahNumber,
  }) async {
    var dbClient = await _db;
    List<Map> maps = await dbClient.query(
      FavoriteAyahsTable.tableName,
      columns: [FavoriteAyahsTable.columnId],
      where:
          '${FavoriteAyahsTable.surahId} = ? AND ${FavoriteAyahsTable.ayahSurah} = ?',
      whereArgs: [surahId, ayahNumber],
    );

    if (maps.isNotEmpty) {
      return true;
    }

    return false;
  }
}
