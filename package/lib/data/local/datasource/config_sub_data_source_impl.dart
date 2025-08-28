import 'dart:async';

import 'package:package/data/local/datasource/config_sub_data_source.dart';
import 'package:package/data/local/table/sub_table.dart';
import 'package:package/domain/model/sub_config.dart';
import 'package:sqflite/sqflite.dart';

class ConfigSubDataSourceImpl implements ConfigSubDataSource {
  final Database db;

  ConfigSubDataSourceImpl({required this.db}) {
    _initStream();
  }

  final _subController = StreamController<SubConfig>.broadcast();

  void _initStream() async {
    final data = await select();
    _subController.add(data);
  }

  Future<void> _emitData() async {
    final data = await select();
    _subController.add(data);
  }

  @override
  Stream<SubConfig> get subStream => _subController.stream;

  @override
  Future<SubConfig> select() async {
    final result = await db.query(
      SubTable.tableName,
      where: '${SubTable.columnId} = ?',
      whereArgs: [0],
    );

    if (result.isEmpty) {
      // Return default config if no data exists
      final defaultConfig = SubConfig(uid: 0, isSub: false, isLifetime: false, isRemoveAd: false);
      // Insert the default config
      await db.insert(SubTable.tableName, defaultConfig.toMap());
      return defaultConfig;
    }

    return result.map((e) => SubConfig.fromMap(e)).toList().first;
  }

  @override
  Future<int> update(SubConfig subConfig) async {
    final rows = await db.update(
      SubTable.tableName,
      subConfig.toMap(),
      where: '${SubTable.columnId} = ?',
      whereArgs: [subConfig.uid],
    );
    await _emitData();
    return rows;
  }

  void dispose() {
    _subController.close();
  }
}