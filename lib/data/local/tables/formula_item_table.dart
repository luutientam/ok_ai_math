class FormulaItemTable {
  static const String tableName = 'formula_item_table';

  static const String uId = 'uid';
  static const String formulaId = 'formula_id';
  static const String name = 'name';
  static const String imagePath = 'image_path';
  static const String isSaved = 'is_saved';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $uId INTEGER PRIMARY KEY AUTOINCREMENT,
        $formulaId INTEGER NOT NULL,
        $name TEXT NOT NULL,
        $imagePath TEXT NOT NULL,
        $isSaved INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($formulaId) REFERENCES formula_table(uid)
      )
    ''';
  }
}
