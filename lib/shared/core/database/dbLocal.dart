import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/database/migration.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_seven_days_item.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'db_habit_daily_summary.dart';

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
    return await openDatabase(path,
        version: _currentVersion, onCreate: _onCreate,
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await migration.migrate(
        db,
        oldVersion: oldVersion,
      );
    }, onOpen: (Database db) async {
      // Temporary dummy data
      await db.transaction((txn) async {
        await txn.execute('''
        insert or ignore into habit_daily_summary (target, total_pages, date) values 
        (5,5,date('now'))
      ''');
      });
    });
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

  Future<HabitDailySummary> getCurrentDayHabitDailySummary() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);

    var dbClient = await _db;
    List<Map<String, Object?>> result = await dbClient.query(
      HabitDailySummaryTable.tableName,
      columns: [
        HabitDailySummaryTable.target,
        HabitDailySummaryTable.totalPages,
        HabitDailySummaryTable.date,
      ],
      orderBy: '${HabitDailySummaryTable.date} DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return HabitDailySummary.fromJson({
        HabitDailySummaryTable.target: 1,
        HabitDailySummaryTable.totalPages: 0,
        HabitDailySummaryTable.date: formattedDate,
      });
    }

    final currentDataQuery = result[0];
    if (currentDataQuery[HabitDailySummaryTable.date] != formattedDate) {
      return HabitDailySummary.fromJson({
        HabitDailySummaryTable.target:
            currentDataQuery[HabitDailySummaryTable.target],
        HabitDailySummaryTable.totalPages: 0,
        HabitDailySummaryTable.date: formattedDate,
      });
    }

    return HabitDailySummary.fromJson(currentDataQuery);
  }

  Future<List<HabitDailySevenDaysItem>> getLastSevenDays(DateTime date) async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    final cleanDate = DateTime(date.year, date.month, date.day);
    final formattedDate = dateFormat.format(cleanDate);
    final sixDayBefore = cleanDate.subtract(const Duration(days: 6));
    final formattedSixDayBefore = dateFormat.format(sixDayBefore);
    final dbClient = await _db;

    List result = await dbClient.query(
      HabitDailySummaryTable.tableName,
      columns: [
        HabitDailySummaryTable.target,
        HabitDailySummaryTable.totalPages,
        HabitDailySummaryTable.date,
      ],
      where:
          '${HabitDailySummaryTable.date} >= ? AND ${HabitDailySummaryTable.date} <= ?',
      whereArgs: [formattedSixDayBefore, formattedDate],
      orderBy: "${HabitDailySummaryTable.date} ASC",
    );

    // init
    List<HabitDailySevenDaysItem> summaryLastSevenDay = [
      for (int index = 0; index < 7; index++)
        HabitDailySevenDaysItem(
          date: sixDayBefore.add(Duration(days: index)),
          totalPages: 0,
          target: 1,
        )
    ];

    for (var element in result) {
      final elementDate = element[HabitDailySummaryTable.date];
      final parsedElementDate =
          DateUtils.stringToDate(elementDate, DateFormatType.yyyyMMdd);
      final difference = parsedElementDate.difference(sixDayBefore).inDays;
      summaryLastSevenDay[difference] =
          HabitDailySevenDaysItem.fromJson(element);
    }

    return summaryLastSevenDay;
  }
}
