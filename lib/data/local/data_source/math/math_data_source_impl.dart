import 'dart:async';

import 'package:flutter_ai_math_2/app.dart';
import 'package:sqflite/sqlite_api.dart';

class MathDataSourceImpl implements MathDataSource {
  final Database db;

  MathDataSourceImpl({required this.db});

  final _mathController = StreamController<List<Math>>.broadcast();

  Future<void> _emitData() async {
    final data = await selectAll();
    _mathController.add(data);
  }

  @override
  Stream<List<Math>> get mathStream async* {
    final data = await selectAll();
    yield data;
    yield* _mathController.stream;
  }

  @override
  Stream<Math?> mathStreamById(int id) async* {
    final initial = await selectById(id);
    yield initial;

    yield* _mathController.stream.map((mathList) {
      final match = mathList.where((c) => c.uid == id);
      return match.isNotEmpty ? match.first : null;
    });
  }

  @override
  Future<List<Math>> selectAll() async {
    final result = await db.query(MathTable.tableName);
    return result.map((e) => Math.fromMap(e)).toList();
  }

  @override
  Future<Math?> selectById(int id) async {
    final result = await db.query(
      MathTable.tableName,
      where: '${MathTable.columnId} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Math.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> insert(Math item) async {
    final id = await db.insert(
      MathTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _emitData(); // Cập nhật stream sau khi thêm mới
    return id;
  }

  @override
  Future<int> update(Math item) async {
    final rows = await db.update(
      MathTable.tableName,
      item.toMap(),
      where: '${MathTable.columnId} = ?',
      whereArgs: [item.uid],
    );
    await _emitData();
    return rows;
  }

  @override
  Future<int> delete(Math item) async {
    final rows = await db.delete(
      MathTable.tableName,
      where: '${MathTable.columnId} = ?',
      whereArgs: [item.uid],
    );
    await _emitData();
    return rows;
  }

  @override
  Future<int> deleteById(int id) async {
    final rows = await db.delete(
      MathTable.tableName,
      where: '${MathTable.columnId} = ?',
      whereArgs: [id],
    );
    await _emitData();
    return rows;
  }

  @override
  void dispose() {
    _mathController.close();
    // Không cần _singleMathControllers nữa
  }
}
