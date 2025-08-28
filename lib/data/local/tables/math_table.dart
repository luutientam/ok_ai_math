class MathTable {
  static const String tableName = 'math_table';

  static const String columnId = 'uid';
  static const String columnResult = 'result';
  static const String columnSolution = 'solution';
  static const String columnImageUri = 'image_uri';
  static const String columnIsFavorite = 'is_favorite';
  static const String columnCreatedAt = 'created_at';

  static String createTableQuery() {
    return '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnResult TEXT NOT NULL,
      $columnSolution TEXT NOT NULL,
      $columnImageUri TEXT NOT NULL,
      $columnIsFavorite INTEGER NOT NULL DEFAULT 0,
      $columnCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  ''';
  }

}