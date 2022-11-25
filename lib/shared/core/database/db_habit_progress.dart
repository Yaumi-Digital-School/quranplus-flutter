class HabitProgressTable {
  static const String tableName = 'habit_progress';
  static const String columnID = 'id';
  static const String uuid = 'uuid';
  static const String pages = 'pages';
  static const String description = 'description';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String habitDailySummaryID = 'habit_daily_summary_id';
  static const String inputTime = 'input_time';
  static const String type = 'type';
}

class HabitProgressType {
  static const String record = 'RECORD';
  static const String manual = 'MANUAL';
}
