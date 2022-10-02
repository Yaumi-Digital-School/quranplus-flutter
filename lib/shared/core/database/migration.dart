import 'dart:developer';

import 'package:qurantafsir_flutter/shared/core/database/db_bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_favorite_ayahs.dart';
import 'package:sqflite/sqflite.dart';

class DbMigration {
  int get migrationsCount => _migrations.length;

  late final List<Function(Database)> _migrations = <Function(Database)>[
    _migrate_1,
    _migrate_2,
    _migrate_3,
  ];

  Future<void> migrate(
    Database db, {
    int oldVersion = 0,
  }) async {
    final int startMigrationIndex = oldVersion;
    log('starting migration index : $startMigrationIndex', name: 'migrations');

    for (int m = startMigrationIndex; m < _migrations.length; m++) {
      log('migration number ${m + 1} started', name: 'migrations');
      await _migrations[m](db);
      log('migration number ${m + 1} succeeded', name: 'migrations');
    }
  }

  Future<void> _migrate_1(Database db) async {
    var sql =
        "CREATE TABLE IF NOT EXISTS ${BookmarksTable.tableName}(${BookmarksTable.columnId} INTEGER PRIMARY KEY, ${BookmarksTable.columnNamaSurat} TEXT, ${BookmarksTable.columnJuz} INTEGER, ${BookmarksTable.columnPage} INTEGER)";
    await db.execute(sql);
  }

  Future<void> _migrate_2(Database db) async {
    await db.transaction((txn) async {
      await txn.execute(
          '''CREATE TABLE IF NOT EXISTS temp_${BookmarksTable.tableName}(
              ${BookmarksTable.columnId} INTEGER PRIMARY KEY, 
              ${BookmarksTable.columnSurahName} TEXT, 
              ${BookmarksTable.columnPage} INTEGER, 
              ${BookmarksTable.columnCreatedAt} TEXT
            )''');
      await txn.execute('''
                INSERT INTO temp_${BookmarksTable.tableName}(
                  ${BookmarksTable.columnSurahName}, 
                  ${BookmarksTable.columnPage})
                SELECT ${BookmarksTable.columnNamaSurat}, ${BookmarksTable.columnPage}
                FROM ${BookmarksTable.tableName}
              ''');
      await txn.execute('DROP TABLE IF EXISTS ${BookmarksTable.tableName}');
      await txn.execute(
          'ALTER TABLE temp_${BookmarksTable.tableName} RENAME TO ${BookmarksTable.tableName}');
    });
  }

  Future<void> _migrate_3(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${FavoriteAyahsTable.tableName}(
        ${FavoriteAyahsTable.columnId} INTEGER PRIMARY KEY,
        ${FavoriteAyahsTable.surahId} INTEGER,
        ${FavoriteAyahsTable.ayahSurah} INTEGER,
        ${FavoriteAyahsTable.page} INTEGER,
        ${FavoriteAyahsTable.ayahHashCode} INTEGER,
        ${FavoriteAyahsTable.createdAt})
    ''');
  }
}
