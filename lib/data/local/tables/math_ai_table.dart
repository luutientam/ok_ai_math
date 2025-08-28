class MathAiTable {
  static const String tableName = 'math_ai_table';

  static const String uId = 'uid';
  static const String isContent = 'is_content';
  static const String createdAt = 'created_at';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $uId INTEGER PRIMARY KEY AUTOINCREMENT,
        $isContent INTEGER NOT NULL,
        $createdAt TEXT NOT NULL
      )
    ''';
  }
}
