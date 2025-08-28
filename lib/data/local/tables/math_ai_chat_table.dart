class MathAiChatTable {
  static const String tableName = 'math_ai_chat_table';

  static const String uid = 'uid';
  static const String mathAi = 'math_ai';
  static const String role = 'role';
  static const String imagePath = 'image_path';
  static const String content = 'content';
  static const String createdAt = 'created_at';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $uid INTEGER PRIMARY KEY AUTOINCREMENT,
        $mathAi INTEGER NOT NULL,
        $role TEXT NOT NULL,
        $imagePath TEXT,
        $content TEXT,
        $createdAt TEXT NOT NULL,
        FOREIGN KEY ($mathAi) REFERENCES math_ai_table(uid)
      )
    ''';
  }
}
