import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_tadabbur_ayah_available.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_tadabbur_reading_content_info.dart';
import 'package:qurantafsir_flutter/shared/core/database/migration.dart';
import 'package:qurantafsir_flutter/shared/core/models/bookmarks.dart';
import 'package:qurantafsir_flutter/shared/core/models/favorite_ayahs.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_daily_summary.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_progress.dart';
import 'package:qurantafsir_flutter/shared/core/models/habit_sync.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

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
          BookmarksTable.tableName,
          bookmark.toMapAfterMergeToServer(),
        );
      }
    });
  }

  //insert ke database
  Future<int?> saveBookmark(Bookmarks bookmark) async {
    var dbClient = await _db;

    return await dbClient.insert(BookmarksTable.tableName, bookmark.toMap());
  }

  //read database
  Future<List?> getBookmarks({
    int? limit,
  }) async {
    final Database dbClient = await _db;
    final List<Map<String, Object?>> result = await dbClient.query(
      BookmarksTable.tableName,
      columns: [
        BookmarksTable.columnId,
        BookmarksTable.columnSurahName,
        BookmarksTable.columnPage,
        BookmarksTable.columnCreatedAt,
      ],
      orderBy: "datetime(${BookmarksTable.columnCreatedAt}) DESC",
      limit: limit,
    );

    return result.toList();
  }

  Future<int?> deleteBookmark(startPage) async {
    var dbClient = await _db;

    return await dbClient.delete(
      BookmarksTable.tableName,
      where: '${BookmarksTable.columnPage} = ?',
      whereArgs: [startPage],
    );
  }

  Future<bool?> oneBookmark(startPage) async {
    var dbClient = await _db;
    List<Map> maps = await dbClient.query(
      BookmarksTable.tableName,
      columns: [
        BookmarksTable.columnId,
        BookmarksTable.columnSurahName,
        BookmarksTable.columnPage,
        BookmarksTable.columnCreatedAt,
      ],
      where: '${BookmarksTable.columnPage} = ?',
      whereArgs: [startPage],
    );
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

  Future<HabitDailySummary?> getHabitDailySummaryByParams({
    DatabaseExecutor? dbClient,
    String? date,
  }) async {
    String whereClause = '';
    List<String> whereArgs = <String>[];

    if (date != null) {
      whereClause += 'date(${HabitDailySummaryTable.date}) = date(?)';
      whereArgs.add(date);
    }

    dbClient ??= await _db;
    List<Map<String, Object?>> result = await dbClient.query(
      HabitDailySummaryTable.tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${HabitDailySummaryTable.date} DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return HabitDailySummary.fromJson(result[0]);
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
        ),
    ];

    for (var element in result) {
      final elementDate = element[HabitDailySummaryTable.date];
      final parsedElementDate =
          DateCustomUtils.stringToDate(elementDate, DateFormatType.yyyyMMdd);
      final difference = parsedElementDate.difference(firstDay).inDays;
      summaryLastSevenDay[difference] = HabitDailySummary.fromJson(element);
    }

    return summaryLastSevenDay;
  }

  Future<int> submitHabitProgressWithDailySummaryByTracking({
    required int pages,
    required int startPage,
    required HabitDailySummary summary,
  }) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);
    final String currentTimestampWithTz = DateCustomUtils.formatISOTime(now);
    final Database dbClient = await _db;

    int progressID = await dbClient.transaction<int>((txn) async {
      late int summaryID;
      if (summary.id == null || summary.formattedDate != formattedDate) {
        final HabitDailySummary newSummary = HabitDailySummary(
          target: summary.target,
          totalPages: summary.totalPages,
          date: summary.date,
          targetUpdatedTime: currentTimestampWithTz,
        );

        summaryID = await txn.insert(
          HabitDailySummaryTable.tableName,
          newSummary.toMap(),
        );
      } else {
        summaryID = summary.id!;
      }

      final int endPage = startPage + pages;
      final int progressID = await insertProgressHistory(
        dbClient: txn,
        uuid: const Uuid().v1(),
        date: now,
        description: 'Page $startPage to $endPage - $pages Pages',
        habitDailySummaryId: summaryID,
        pages: pages,
        type: HabitProgressType.record,
      );

      final int totalReadPages = pages + (summary.totalPages);
      await txn.rawUpdate(
        '''
        UPDATE ${HabitDailySummaryTable.tableName}
        SET ${HabitDailySummaryTable.totalPages} = $totalReadPages,
            ${HabitDailySummaryTable.updatedAt} = '$currentTimestampWithTz'
        WHERE ${HabitDailySummaryTable.columnID} = ?
      ''',
        [summaryID],
      );

      return progressID;
    });

    return progressID;
  }

  Future<List<HabitProgress>> getProgressHistory(
    int habitDailySummaryId,
  ) async {
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
    DatabaseExecutor? dbClient,
    required DateTime date,
    required int habitDailySummaryId,
    required String type,
    required String uuid,
    required int pages,
    required String description,
  }) async {
    final DateFormat formatTime = DateFormat("HH:mm:ss");
    final String formattedTime = formatTime.format(date);

    dbClient ??= await _db;

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

  Future<int> insertHabitDailySummary({
    DatabaseExecutor? db,
    required DateTime date,
    required int target,
    required int totalPages,
  }) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);
    final String currentTimestampWithTz = DateCustomUtils.formatISOTime(date);
    db ??= await _db;

    return await db.insert(
      HabitDailySummaryTable.tableName,
      {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPages,
        HabitDailySummaryTable.date: formattedDate,
        HabitDailySummaryTable.targetUpdatedTime: currentTimestampWithTz,
      },
    );
  }

  Future<int> updateHabitDailySummary({
    DatabaseExecutor? db,
    required int id,
    required DateTime date,
    required int target,
    required int totalPages,
  }) async {
    final String targetUpdatedTimeWithTz = DateCustomUtils.formatISOTime(date);
    final DateTime now = DateTime.now();
    final String nowWithTz = DateCustomUtils.formatISOTime(now);
    db ??= await _db;

    return await db.update(
      HabitDailySummaryTable.tableName,
      {
        HabitDailySummaryTable.target: target,
        HabitDailySummaryTable.totalPages: totalPages,
        HabitDailySummaryTable.targetUpdatedTime: targetUpdatedTimeWithTz,
        HabitDailySummaryTable.updatedAt: nowWithTz,
      },
      where: "${HabitDailySummaryTable.columnID} = ?",
      whereArgs: [id],
    );
  }

  Future<void> upsertHabitDailySummaryOnSync({
    required List<HabitSyncResponseItem> response,
  }) async {
    List<HabitProgress> progressToBeCreated = <HabitProgress>[];
    Database dbClient = await _db;
    await dbClient.transaction((txn) async {
      for (HabitSyncResponseItem item in response) {
        late int selectedID;
        final HabitDailySummary? data = await getHabitDailySummaryByParams(
          dbClient: txn,
          date: item.date,
        );

        if (data != null) {
          selectedID = data.id!;
          await updateHabitDailySummary(
            db: txn,
            id: selectedID,
            date: DateTime.parse(item.targetUpdatedAt),
            target: item.target,
            totalPages: item.totalPages,
          );
        } else {
          selectedID = await insertHabitDailySummary(
            db: txn,
            date: DateTime.parse(item.date),
            target: item.target,
            totalPages: item.totalPages,
          );
        }

        for (HabitSyncResponseProgressItem progressItem
            in item.habitProgresses) {
          final HabitProgress progress = HabitProgress(
            uuid: progressItem.uuid,
            pages: progressItem.pages,
            description: progressItem.description,
            habitDailySummaryID: selectedID,
            inputTime: progressItem.inputTime,
            type: progressItem.type,
          );

          progressToBeCreated.add(progress);
        }
      }

      for (HabitProgress progress in progressToBeCreated) {
        await txn.rawInsert(
          '''
            INSERT OR IGNORE INTO ${HabitProgressTable.tableName} 
            (${HabitProgressTable.uuid}, ${HabitProgressTable.description}, ${HabitProgressTable.habitDailySummaryID}, ${HabitProgressTable.inputTime}, ${HabitProgressTable.type}, ${HabitProgressTable.pages})
            VALUES (?, ?, ?, ?, ?, ?)
        ''',
          [
            progress.uuid,
            progress.description,
            progress.habitDailySummaryID,
            progress.inputTime,
            progress.type,
            progress.pages,
          ],
        );
      }
    });
  }

  Future<List<HabitSyncRequestDailySummaryItem>> getLocalDbToSync(
    SharedPreferenceService sharedPreferenceService,
  ) async {
    try {
      final String lastSyncDate = sharedPreferenceService.getLastSync();
      var dbClient = await _db;

      final resultQueryHabitDaily = await dbClient.rawQuery(
        '''
            SELECT ${HabitDailySummaryTable.target},
             ${HabitDailySummaryTable.date},
             ${HabitDailySummaryTable.targetUpdatedTime},
             ${HabitDailySummaryTable.columnID}
             FROM ${HabitDailySummaryTable.tableName}
             WHERE datetime(${HabitDailySummaryTable.updatedAt}) > datetime('$lastSyncDate')
             AND (JULIANDAY('now') - JULIANDAY(${HabitDailySummaryTable.updatedAt})) <= 7
             ORDER BY ${HabitDailySummaryTable.date} ASC;
       ''',
      );
      final List<HabitSyncRequestDailySummaryItem> result = [];

      for (var element in resultQueryHabitDaily) {
        final habitProgress = await getHabitProgressToSync(
          element[HabitDailySummaryTable.columnID] as int,
          lastSyncDate,
        );

        result.add(
          HabitSyncRequestDailySummaryItem(
            date: element[HabitDailySummaryTable.date] as String,
            progresses: habitProgress,
            target: element[HabitDailySummaryTable.target] as int,
            targetUpdatedAt:
                element[HabitDailySummaryTable.targetUpdatedTime] as String,
          ),
        );
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List<HabitSyncRequestProgressItem>> getHabitProgressToSync(
    int id,
    String lastSyncDate,
  ) async {
    var dbClient = await _db;
    final resultQueryHabitProgress = await dbClient.rawQuery(
      '''SELECT 
         ${HabitProgressTable.uuid},
         ${HabitProgressTable.pages},
         ${HabitProgressTable.description},
         ${HabitProgressTable.inputTime},
         ${HabitProgressTable.type}
         FROM ${HabitProgressTable.tableName}
         WHERE datetime(${HabitProgressTable.createdAt}) > datetime('$lastSyncDate')
         AND (JULIANDAY('now') - JULIANDAY(${HabitProgressTable.createdAt})) <= 7
      ''',
    );

    final List<HabitSyncRequestProgressItem> result = [];
    for (var element in resultQueryHabitProgress) {
      result.add(HabitSyncRequestProgressItem.fromJson(element));
    }

    return result;
  }

  Future<void> clearTableHabit() async {
    final Database db = await _db;
    await db.transaction((txn) async {
      await txn.delete(HabitProgressTable.tableName);
      await txn.delete(HabitDailySummaryTable.tableName);
    });
  }

  /*
    TADABBUR AYAH AVAILABLE
  */

  Future<void> bulkReplaceTadabburAyahAvailables(
    Map<int, List<int>> listOfKeyValues,
  ) async {
    final Database db = await _db;

    String values = '';

    listOfKeyValues.forEach((key, value) {
      values += "($key, '$value'),";
    });

    values = values.substring(0, values.length - 1);

    await db.transaction((txn) async {
      await txn.delete(TadabburAyahAvailableTable.tableName);

      await txn.rawInsert(
        '''
        INSERT INTO ${TadabburAyahAvailableTable.tableName} 
        (${TadabburAyahAvailableTable.surahID}, ${TadabburAyahAvailableTable.listOfAyahInStr})
        VALUES $values
      ''',
      );
    });
  }

  Future<List> getTadabburAyahAvailables() async {
    final Database db = await _db;

    List resultQuery = await db.query(
      TadabburAyahAvailableTable.tableName,
    );

    return resultQuery;
  }

  Future<List> GetTadabburSurahAvailable() async {
    var dbClient = await _db;
    final resultQueryTadabburAvailable =
        await dbClient.query(TadabburTable.tableName);

    return resultQueryTadabburAvailable;
  }

  Future<void> bulkReplaceTadabburSurahAvailables(
    Map<int, int> listOfKeyValuesTadabburSurah,
  ) async {
    final Database db = await _db;

    String values = '';

    listOfKeyValuesTadabburSurah.forEach((key, value) {
      values += "($key, '$value'),";
    });

    values = values.substring(0, values.length - 1);

    await db.transaction((txn) async {
      await txn.delete(TadabburTable.tableName);

      await txn.rawInsert(
        '''
        INSERT INTO ${TadabburTable.tableName} 
        (${TadabburTable.surahID}, ${TadabburTable.totalTadabbur})
        VALUES $values
      ''',
      );
    });
  }

  /*
    TADABBUR READING CONTENT INFO
  */

  Future<int> getTadabburReadingContentInfoByTadabburID(int tadabburID) async {
    final Database dbClient = await _db;
    final List<Map<String, dynamic>> result = await dbClient.query(
      TadabburReadingContentInfoTable.tableName,
      columns: [TadabburReadingContentInfoTable.lastReadingIndex],
      where: '${TadabburReadingContentInfoTable.tadabburID} = $tadabburID',
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return result[0][TadabburReadingContentInfoTable.lastReadingIndex];
  }

  Future<int> insertOrupdateTadabburReadingContentInfoLastReadingIndex({
    required int tadabburID,
    required int lastReadingIndex,
  }) async {
    final Database dbClient = await _db;

    int res = await dbClient.rawInsert('''
        INSERT OR IGNORE INTO ${TadabburReadingContentInfoTable.tableName}
        (${TadabburReadingContentInfoTable.tadabburID}, ${TadabburReadingContentInfoTable.lastReadingIndex})
        VALUES ($tadabburID, $lastReadingIndex)
      ''');

    if (res == 0) {
      res = await dbClient.rawUpdate('''
        UPDATE ${TadabburReadingContentInfoTable.tableName}
        SET ${TadabburReadingContentInfoTable.lastReadingIndex} = $lastReadingIndex
        WHERE ${TadabburReadingContentInfoTable.tadabburID} = $tadabburID
      ''');
    }

    return res;
  }
}
