class FormulaTable {
  static const String tableName = 'formula_table';

  static const String uId = 'uid';
  static const String name = 'name';
  static const String iconPath = 'icon_path';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $uId INTEGER PRIMARY KEY AUTOINCREMENT,
        $name TEXT NOT NULL,
        $iconPath TEXT NOT NULL
      )
    ''';
  }
}
