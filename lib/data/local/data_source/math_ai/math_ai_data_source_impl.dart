import 'dart:async';
import 'package:flutter_ai_math_2/app.dart';
import 'package:sqflite/sqlite_api.dart';

import 'math_ai_data_source.dart';

class MathAiDataSourceImpl implements MathAiDataSource {
  final Database db;

  MathAiDataSourceImpl({required this.db});

  // StreamController để phát sự kiện khi data thay đổi
  final StreamController<List<MathAi>> _mathAiStreamController =
      StreamController<List<MathAi>>.broadcast();

  // Map để lưu StreamController cho từng ID
  final Map<int, StreamController<MathAi?>> _mathAiByIdControllers = {};

  @override
  Stream<List<MathAi>> watchAll() {
    // Emit initial data
    _emitCurrentData();

    // Return stream
    return _mathAiStreamController.stream;
  }

  @override
  Stream<MathAi?> watchById(int id) {
    // Tạo StreamController cho ID này nếu chưa có
    if (!_mathAiByIdControllers.containsKey(id)) {
      _mathAiByIdControllers[id] = StreamController<MathAi?>.broadcast();
    }

    // Emit initial data cho ID này
    _emitCurrentDataById(id);

    // Return stream cho ID này
    return _mathAiByIdControllers[id]!.stream;
  }

  // Helper method để emit data hiện tại
  Future<void> _emitCurrentData() async {
    try {
      final mathAis = await selectAll();
      _mathAiStreamController.add(mathAis);
    } catch (e) {
      _mathAiStreamController.addError(e);
    }
  }

  // Helper method để emit data hiện tại cho một ID cụ thể
  Future<void> _emitCurrentDataById(int id) async {
    try {
      final mathAi = await selectById(id);
      if (_mathAiByIdControllers.containsKey(id)) {
        _mathAiByIdControllers[id]!.add(mathAi);
      }
    } catch (e) {
      if (_mathAiByIdControllers.containsKey(id)) {
        _mathAiByIdControllers[id]!.addError(e);
      }
    }
  }

  // Helper method để emit data cho tất cả các ID streams
  Future<void> _emitAllByIdStreams() async {
    for (final id in _mathAiByIdControllers.keys) {
      await _emitCurrentDataById(id);
    }
  }

  @override
  Future<List<MathAi>> selectAll() async {
    final result = await db.query(
      MathAiTable.tableName,
      orderBy: '${MathAiTable.createdAt} DESC',
    );
    return result.map((e) => MathAi.fromMap(e)).toList();
  }

  @override
  Future<MathAi?> selectById(int id) async {
    final result = await db.query(
      MathAiTable.tableName,
      where: '${MathAiTable.uId} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MathAi.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> insert(MathAi item) async {
    final id = await db.insert(
      MathAiTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Emit updated data sau khi insert
    await _emitCurrentData();
    await _emitAllByIdStreams();

    return id;
  }

  @override
  Future<int> update(MathAi item) async {
    final row = await db.update(
      MathAiTable.tableName,
      item.toMap(),
      where: '${MathAiTable.uId} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi update
    await _emitCurrentData();

    // Emit data đặc biệt cho ID đã update
    if (item.uid != null) {
      await _emitCurrentDataById(item.uid!);
    }

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  @override
  Future<int> delete(MathAi item) async {
    final row = await db.delete(
      MathAiTable.tableName,
      where: '${MathAiTable.uId} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi delete
    await _emitCurrentData();

    // Emit null cho ID đã bị xóa
    if (item.uid != null && _mathAiByIdControllers.containsKey(item.uid)) {
      _mathAiByIdControllers[item.uid]!.add(null);
    }

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  @override
  Future<List<int>> deleteAll(List<MathAi> items) async {
    final results = <int>[];
    for (final item in items) {
      final result = await delete(item);
      results.add(result);
    }
    return results;
  }

  // Method để manually trigger stream update cho một ID cụ thể
  void refreshStreamById(int id) {
    _emitCurrentDataById(id);
  }

  // Method để cleanup StreamController cho một ID không còn sử dụng
  void disposeStreamById(int id) {
    if (_mathAiByIdControllers.containsKey(id)) {
      _mathAiByIdControllers[id]!.close();
      _mathAiByIdControllers.remove(id);
    }
  }

  @override
  void dispose() {
    _mathAiStreamController.close();

    // Đóng tất cả byId streams
    for (final controller in _mathAiByIdControllers.values) {
      controller.close();
    }
    _mathAiByIdControllers.clear();
  }
}
