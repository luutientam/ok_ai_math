import 'package:flutter_ai_math_2/app.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'flutter_stamp.db';
  static const _dbVersion = 1;

  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(MathTable.createTableQuery());
    await db.execute(FormulaTable.createTableQuery());
    await db.execute(FormulaItemTable.createTableQuery());
    await db.execute(MathAiTable.createTableQuery());
    await db.execute(MathAiChatTable.createTableQuery());

    await onCreateFormulaTable(db);
    await onCreateFormulaItemTable(db);
  }

  static Future<void> onCreateFormulaTable(Database db) async {
    for (final formula in FormulaData.formulas) {
      final id = await db.insert(
        FormulaTable.tableName,
        formula.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('[DatabaseHelper] Inserted formula: ${formula.name} with id=$id');
    }
  }

  static Future<void> onCreateFormulaItemTable(Database db) async {
    for (final formulaItem in FormulaItemData.formulaItems) {
      final id = await db.insert(
        FormulaItemTable.tableName,
        formulaItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(
        '[DatabaseHelper] Inserted formula item: ${formulaItem.name} with id=$id',
      );
    }
  }
}
