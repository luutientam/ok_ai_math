import 'dart:async';
import 'package:flutter_ai_math_2/app.dart';
import 'package:sqflite/sqflite.dart';

import 'math_ai_chat_data_source.dart';

class MathAiChatDataSourceImpl implements MathAiChatDataSource {
  final Database db;

  MathAiChatDataSourceImpl({required this.db});

  // StreamController để phát sự kiện khi data thay đổi
  final StreamController<List<MathAiChat>> _mathAiChatStreamController =
      StreamController<List<MathAiChat>>.broadcast();

  // Map để lưu StreamController cho từng ID
  final Map<int, StreamController<MathAiChat?>> _mathAiChatByIdControllers = {};

  // Map để lưu StreamController cho từng Math AI ID
  final Map<int, StreamController<List<MathAiChat>>>
  _mathAiChatByMathAiIdControllers = {};

  @override
  Stream<List<MathAiChat>> watchAll() {
    // Emit initial data
    _emitCurrentData();

    // Return stream
    return _mathAiChatStreamController.stream;
  }

  @override
  Stream<MathAiChat?> watchById(int id) {
    // Tạo StreamController cho ID này nếu chưa có
    if (!_mathAiChatByIdControllers.containsKey(id)) {
      _mathAiChatByIdControllers[id] =
          StreamController<MathAiChat?>.broadcast();
    }

    // Emit initial data cho ID này
    _emitCurrentDataById(id);

    // Return stream cho ID này
    return _mathAiChatByIdControllers[id]!.stream;
  }

  @override
  Stream<List<MathAiChat>> watchByMathAiId(int mathAiId) {
    // Tạo StreamController cho mathAiId này nếu chưa có
    if (!_mathAiChatByMathAiIdControllers.containsKey(mathAiId)) {
      _mathAiChatByMathAiIdControllers[mathAiId] =
          StreamController<List<MathAiChat>>.broadcast();
    }

    // Emit initial data cho mathAiId này
    _emitCurrentDataByMathAiId(mathAiId);

    // Return stream cho mathAiId này
    return _mathAiChatByMathAiIdControllers[mathAiId]!.stream;
  }

  // Helper method để emit data hiện tại
  Future<void> _emitCurrentData() async {
    try {
      final mathAiChats = await selectAll();
      _mathAiChatStreamController.add(mathAiChats);
    } catch (e) {
      _mathAiChatStreamController.addError(e);
    }
  }

  // Helper method để emit data hiện tại cho một ID cụ thể
  Future<void> _emitCurrentDataById(int id) async {
    try {
      final mathAiChat = await selectById(id);
      if (_mathAiChatByIdControllers.containsKey(id)) {
        _mathAiChatByIdControllers[id]!.add(mathAiChat);
      }
    } catch (e) {
      if (_mathAiChatByIdControllers.containsKey(id)) {
        _mathAiChatByIdControllers[id]!.addError(e);
      }
    }
  }

  // Helper method để emit data hiện tại cho một mathAiId cụ thể
  Future<void> _emitCurrentDataByMathAiId(int mathAiId) async {
    try {
      final mathAiChats = await selectByMathAiId(mathAiId);
      if (_mathAiChatByMathAiIdControllers.containsKey(mathAiId)) {
        _mathAiChatByMathAiIdControllers[mathAiId]!.add(mathAiChats);
      }
    } catch (e) {
      if (_mathAiChatByMathAiIdControllers.containsKey(mathAiId)) {
        _mathAiChatByMathAiIdControllers[mathAiId]!.addError(e);
      }
    }
  }

  // Helper method để emit data cho tất cả các ID streams
  Future<void> _emitAllByIdStreams() async {
    for (final id in _mathAiChatByIdControllers.keys) {
      await _emitCurrentDataById(id);
    }
  }

  // Helper method để emit data cho tất cả các mathAiId streams
  Future<void> _emitAllByMathAiIdStreams() async {
    for (final mathAiId in _mathAiChatByMathAiIdControllers.keys) {
      await _emitCurrentDataByMathAiId(mathAiId);
    }
  }

  @override
  Future<List<MathAiChat>> selectAll() async {
    final result = await db.query(
      MathAiChatTable.tableName,
      orderBy: '${MathAiChatTable.createdAt} ASC',
    );
    return result.map((e) => MathAiChat.fromMap(e)).toList();
  }

  @override
  Future<MathAiChat?> selectById(int id) async {
    final result = await db.query(
      MathAiChatTable.tableName,
      where: '${MathAiChatTable.uid} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MathAiChat.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<List<MathAiChat>> selectByMathAiId(int mathAiId) async {
    final result = await db.query(
      MathAiChatTable.tableName,
      where: '${MathAiChatTable.mathAi} = ?',
      whereArgs: [mathAiId],
      orderBy: '${MathAiChatTable.createdAt} ASC',
    );
    return result.map((e) => MathAiChat.fromMap(e)).toList();
  }

  @override
  Future<int> insert(MathAiChat item) async {
    final id = await db.insert(
      MathAiChatTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Emit updated data sau khi insert
    await _emitCurrentData();
    await _emitAllByIdStreams();
    await _emitCurrentDataByMathAiId(item.mathAi);

    return id;
  }

  @override
  Future<int> update(MathAiChat item) async {
    final row = await db.update(
      MathAiChatTable.tableName,
      item.toMap(),
      where: '${MathAiChatTable.uid} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi update
    await _emitCurrentData();

    // Emit data đặc biệt cho ID đã update
    if (item.uid != null) {
      await _emitCurrentDataById(item.uid!);
    }

    // Emit data cho mathAiId stream
    await _emitCurrentDataByMathAiId(item.mathAi);

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  @override
  Future<int> delete(MathAiChat item) async {
    final row = await db.delete(
      MathAiChatTable.tableName,
      where: '${MathAiChatTable.uid} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi delete
    await _emitCurrentData();

    // Emit null cho ID đã bị xóa
    if (item.uid != null && _mathAiChatByIdControllers.containsKey(item.uid)) {
      _mathAiChatByIdControllers[item.uid]!.add(null);
    }

    // Emit data cho mathAiId stream
    await _emitCurrentDataByMathAiId(item.mathAi);

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  @override
  Future<List<int>> deleteAll(List<MathAiChat> items) async {
    final results = <int>[];
    for (final item in items) {
      final result = await delete(item);
      results.add(result);
    }
    return results;
  }

  @override
  Future<int> deleteByMathAiId(int mathAiId) async {
    final row = await db.delete(
      MathAiChatTable.tableName,
      where: '${MathAiChatTable.mathAi} = ?',
      whereArgs: [mathAiId],
    );

    // Emit updated data sau khi delete
    await _emitCurrentData();
    await _emitCurrentDataByMathAiId(mathAiId);
    await _emitAllByIdStreams();

    return row;
  }

  // Method để manually trigger stream update cho một ID cụ thể
  void refreshStreamById(int id) {
    _emitCurrentDataById(id);
  }

  // Method để manually trigger stream update cho một mathAiId cụ thể
  void refreshStreamByMathAiId(int mathAiId) {
    _emitCurrentDataByMathAiId(mathAiId);
  }

  // Method để cleanup StreamController cho một ID không còn sử dụng
  void disposeStreamById(int id) {
    if (_mathAiChatByIdControllers.containsKey(id)) {
      _mathAiChatByIdControllers[id]!.close();
      _mathAiChatByIdControllers.remove(id);
    }
  }

  // Method để cleanup StreamController cho một mathAiId không còn sử dụng
  void disposeStreamByMathAiId(int mathAiId) {
    if (_mathAiChatByMathAiIdControllers.containsKey(mathAiId)) {
      _mathAiChatByMathAiIdControllers[mathAiId]!.close();
      _mathAiChatByMathAiIdControllers.remove(mathAiId);
    }
  }

  @override
  void dispose() {
    _mathAiChatStreamController.close();

    // Đóng tất cả byId streams
    for (final controller in _mathAiChatByIdControllers.values) {
      controller.close();
    }
    _mathAiChatByIdControllers.clear();

    // Đóng tất cả byMathAiId streams
    for (final controller in _mathAiChatByMathAiIdControllers.values) {
      controller.close();
    }
    _mathAiChatByMathAiIdControllers.clear();
  }
}
