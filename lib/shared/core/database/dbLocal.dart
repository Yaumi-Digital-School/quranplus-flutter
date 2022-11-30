import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/database/migration.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_progress.dart';
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

  Future<HabitDailySummary> getCurrentDayHabitDailySummary() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);

    var dbClient = await _db;
    List<Map<String, Object?>> result = await dbClient.query(
      HabitDailySummaryTable.tableName,
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

  Future<List<HabitDailySummary>> getLastSevenDays(DateTime date) async {
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

    final queryBeforeSixDay = await dbClient.query(
      HabitDailySummaryTable.tableName,
      columns: [
        HabitDailySummaryTable.date,
      ],
      where: '${HabitDailySummaryTable.date} < ?',
      whereArgs: [formattedSixDayBefore],
      limit: 1,
    );

    late DateTime firstDay;

    if (queryBeforeSixDay.isNotEmpty) {
      firstDay = sixDayBefore;
    } else {
      firstDay = result.isEmpty
          ? cleanDate
          : DateTime.parse(result[0][HabitDailySummaryTable.date]);
    }

    // init
    List<HabitDailySummary> summaryLastSevenDay = [
      for (int index = 0; index < 7; index++)
        HabitDailySummary(
          date: firstDay.add(Duration(days: index)),
          totalPages: 0,
          target: 1,
        )
    ];

    for (var element in result) {
      final elementDate = element[HabitDailySummaryTable.date];
      final parsedElementDate =
          DateUtils.stringToDate(elementDate, DateFormatType.yyyyMMdd);
      final difference = parsedElementDate.difference(firstDay).inDays;
      summaryLastSevenDay[difference] = HabitDailySummary.fromJson(element);
    }

    return summaryLastSevenDay;
  }

  Future<List<HabitProgress>> getProgressHistory(
      int habitDailySummaryId) async {
    final dbClient = await _db;
    List resultQuery = await dbClient.query(
      HabitProgressTable.tableName,
      where: "${HabitProgressTable.habitDailySummaryID} = ?",
      whereArgs: [habitDailySummaryId],
    );

    final List<HabitProgress> result = [];
    for (var element in resultQuery) {
      result.add(HabitProgress.fromJson(element));
    }

    return result;
  }

  Future<int> insertProgressHistory({
    required DateTime date,
    required int habitDailySummaryId,
    required String type,
    required String uuid,
    required int pages,
    required String description,
  }) async {
    final DateFormat formatTime = DateFormat("HH:mm:ss");
    final String formattedTime = formatTime.format(date);
    var dbClient = await _db;

    return await dbClient.insert(HabitProgressTable.tableName, {
      HabitProgressTable.uuid: uuid,
      HabitProgressTable.pages: pages,
      HabitProgressTable.habitDailySummaryID: habitDailySummaryId,
      HabitProgressTable.description: description,
      HabitProgressTable.type: type,
      HabitProgressTable.inputTime: formattedTime,
    });
  }

  Future<HabitDailySummary?> getExactHabitDailySummary() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);

    var dbClient = await _db;
    List<Map<String, Object?>> result = await dbClient.query(
      HabitDailySummaryTable.tableName,
      where: "${HabitDailySummaryTable.date} = ?",
      whereArgs: [formattedDate],
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }

    final currentDataQuery = result[0];

    return HabitDailySummary.fromJson(currentDataQuery);
  }

  Future<int> insertHabitDailySummary(
      DateTime date, int target, int totalPages) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateFormat formatTime = DateFormat("HH:mm:ss");
    final String formattedDate = formatter.format(date);
    final String formattedTime = formatTime.format(date);
    var dbClient = await _db;

    return await dbClient.insert(
      HabitDailySummaryTable.tableName,
      {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPages,
        HabitDailySummaryTable.date: formattedDate,
        HabitDailySummaryTable.targetUpdatedTime: formattedTime,
      },
    );
  }

  Future<int> updateHabitDailySummary(
      int id, DateTime date, int target, int totalPages) async {
    final DateFormat formatTime = DateFormat("HH:mm:ss");
    final String formattedTime = formatTime.format(date);
    var dbClient = await _db;

    return await dbClient.update(
      HabitDailySummaryTable.tableName,
      {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPages,
        HabitDailySummaryTable.targetUpdatedTime: formattedTime,
      },
      where: "${HabitDailySummaryTable.columnID} = ?",
      whereArgs: [id],
    );
  }
}
