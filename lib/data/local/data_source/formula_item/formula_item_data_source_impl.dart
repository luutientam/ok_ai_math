import 'dart:async';
import 'package:flutter_ai_math_2/app.dart';
import 'package:sqflite/sqlite_api.dart';

class FormulaItemDataSourceImpl implements FormulaItemDataSource {
  final Database db;

  FormulaItemDataSourceImpl({required this.db});

  // StreamController để phát sự kiện khi data thay đổi
  final StreamController<List<FormulaItem>> _formulaItemStreamController =
      StreamController<List<FormulaItem>>.broadcast();

  // Map để lưu StreamController cho từng ID
  final Map<int, StreamController<FormulaItem?>> _formulaItemByIdControllers =
      {};

  @override
  Stream<List<FormulaItem>> watchAll() {
    // Emit initial data
    _emitCurrentData();

    // Return stream
    return _formulaItemStreamController.stream;
  }

  @override
  Stream<FormulaItem?> watchById(int id) {
    // Tạo StreamController cho ID này nếu chưa có
    if (!_formulaItemByIdControllers.containsKey(id)) {
      _formulaItemByIdControllers[id] =
          StreamController<FormulaItem?>.broadcast();
    }

    // Emit initial data cho ID này
    _emitCurrentDataById(id);

    // Return stream cho ID này
    return _formulaItemByIdControllers[id]!.stream;
  }

  // Helper method để emit data hiện tại
  Future<void> _emitCurrentData() async {
    try {
      final formulaItems = await selectAll();
      _formulaItemStreamController.add(formulaItems);
    } catch (e) {
      _formulaItemStreamController.addError(e);
    }
  }

  // Helper method để emit data hiện tại cho một ID cụ thể
  Future<void> _emitCurrentDataById(int id) async {
    try {
      final formulaItem = await selectById(id);
      if (_formulaItemByIdControllers.containsKey(id)) {
        _formulaItemByIdControllers[id]!.add(formulaItem);
      }
    } catch (e) {
      if (_formulaItemByIdControllers.containsKey(id)) {
        _formulaItemByIdControllers[id]!.addError(e);
      }
    }
  }

  // Helper method để emit data cho tất cả các ID streams
  Future<void> _emitAllByIdStreams() async {
    for (final id in _formulaItemByIdControllers.keys) {
      await _emitCurrentDataById(id);
    }
  }

  @override
  Future<List<FormulaItem>> selectAll() async {
    final result = await db.query(FormulaItemTable.tableName);
    return result.map((e) => FormulaItem.fromMap(e)).toList();
  }

  @override
  Future<FormulaItem?> selectById(int id) async {
    final result = await db.query(
      FormulaItemTable.tableName,
      where: '${FormulaItemTable.uId} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return FormulaItem.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> insert(FormulaItem item) async {
    final id = await db.insert(
      FormulaItemTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _emitCurrentData();

    await _emitAllByIdStreams();
    return id;
  }

  @override
  Future<int> update(FormulaItem item) async {
    final row = await db.update(
      FormulaItemTable.tableName,
      item.toMap(),
      where: '${FormulaItemTable.uId} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi update
    _emitCurrentData();

    // Emit data đặc biệt cho ID đã update
    if (item.uid != null) {
      await _emitCurrentDataById(item.uid!);
    }

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  @override
  Future<int> delete(FormulaItem item) async {
    final row = await db.delete(
      FormulaItemTable.tableName,
      where: '${FormulaItemTable.uId} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi delete
    _emitCurrentData();

    // Emit null cho ID đã bị xóa
    if (item.uid != null && _formulaItemByIdControllers.containsKey(item.uid)) {
      _formulaItemByIdControllers[item.uid]!.add(null);
    }

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  // Method để manually trigger stream update cho một ID cụ thể
  void refreshStreamById(int id) {
    _emitCurrentDataById(id);
  }

  // Method để cleanup StreamController cho một ID không còn sử dụng
  void disposeStreamById(int id) {
    if (_formulaItemByIdControllers.containsKey(id)) {
      _formulaItemByIdControllers[id]!.close();
      _formulaItemByIdControllers.remove(id);
    }
  }

  @override
  void dispose() {
    _formulaItemStreamController.close();

    // Đóng tất cả byId streams
    for (final controller in _formulaItemByIdControllers.values) {
      controller.close();
    }
    _formulaItemByIdControllers.clear();
  }
}
