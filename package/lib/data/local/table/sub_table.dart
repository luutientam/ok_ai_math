class SubTable {
  static const String tableName = 'sub_table';

  static const String columnId = 'uid';
  static const String columnIsSub = 'is_sub';
  static const String columnIsLifetime = 'is_lifetime';
  static const String columnIsRemoveAd = 'is_remove_ad';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnIsSub BOOL NOT NULL,
        $columnIsLifetime BOOL NOT NULL,
        $columnIsRemoveAd BOOL NOT NULL
      )
    ''';
  }
}