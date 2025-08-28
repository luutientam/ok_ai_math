import 'package:package/data/local/table/sub_table.dart';
import 'package:package/domain/model/sub_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SubDatabase {
  static const _dbName = 'sub_config.db';
  static const _dbVersion = 1;

  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    await deleteDatabase(path);

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
    await db.execute(SubTable.createTableQuery());

    await _insertInitialData(db);
  }

  static Future<void> _insertInitialData(Database db) async {
    final sub = SubConfig(
      uid: 0,
      isSub: false,
      isLifetime: false,
      isRemoveAd: false,
    );

    await db.insert(SubTable.tableName, sub.toMap());
  }
}