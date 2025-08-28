import 'dart:async';
import 'package:flutter_ai_math_2/app.dart';
import 'package:sqflite/sqlite_api.dart';

class FormulaDataSourceImpl implements FormulaDataSource {
  final Database db;

  // StreamController để phát sự kiện khi data thay đổi
  final StreamController<List<Formula>> _formulaStreamController =
      StreamController<List<Formula>>.broadcast();

  // Map để lưu StreamController cho từng ID
  final Map<int, StreamController<Formula?>> _formulaByIdControllers = {};

  FormulaDataSourceImpl({required this.db});

  @override
  Stream<List<Formula>> watchAll() {
    // Emit initial data
    _emitCurrentData();

    // Return stream
    return _formulaStreamController.stream;
  }

  @override
  Stream<Formula?> watchById(int id) {
    // Tạo StreamController cho ID này nếu chưa có
    if (!_formulaByIdControllers.containsKey(id)) {
      _formulaByIdControllers[id] = StreamController<Formula?>.broadcast();
    }

    // Emit initial data cho ID này
    _emitCurrentDataById(id);

    // Return stream cho ID này
    return _formulaByIdControllers[id]!.stream;
  }

  // Helper method để emit data hiện tại
  Future<void> _emitCurrentData() async {
    try {
      final formulas = await selectAll();
      print(
        '[FormulaDataSource] _emitCurrentData formulas count=${formulas.length}',
      );
      _formulaStreamController.add(formulas);
    } catch (e) {
      print('[FormulaDataSource] _emitCurrentData error: $e');
      _formulaStreamController.addError(e);
    }
  }

  // Helper method để emit data hiện tại cho một ID cụ thể
  Future<void> _emitCurrentDataById(int id) async {
    try {
      final formula = await selectById(id);
      if (_formulaByIdControllers.containsKey(id)) {
        _formulaByIdControllers[id]!.add(formula);
      }
    } catch (e) {
      if (_formulaByIdControllers.containsKey(id)) {
        _formulaByIdControllers[id]!.addError(e);
      }
    }
  }

  // Helper method để emit data cho tất cả các ID streams
  Future<void> _emitAllByIdStreams() async {
    for (final id in _formulaByIdControllers.keys) {
      await _emitCurrentDataById(id);
    }
  }

  @override
  Future<List<Formula>> selectAll() async {
    final result = await db.query(FormulaTable.tableName);
    return result.map((e) => Formula.fromMap(e)).toList();
  }

  @override
  Future<Formula?> selectById(int id) async {
    final result = await db.query(
      FormulaTable.tableName,
      where: '${FormulaTable.uId} = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Formula.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> insert(Formula item) async {
    final id = await db.insert(
      FormulaTable.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Emit updated data sau khi insert
    _emitCurrentData();

    // Emit data cho các byId streams nếu có
    await _emitAllByIdStreams();

    return id;
  }

  @override
  Future<int> update(Formula item) async {
    final row = await db.update(
      FormulaTable.tableName,
      item.toMap(),
      where: '${FormulaTable.uId} = ?',
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
  Future<int> delete(Formula item) async {
    final row = await db.delete(
      FormulaTable.tableName,
      where: '${FormulaTable.uId} = ?',
      whereArgs: [item.uid],
    );

    // Emit updated data sau khi delete
    _emitCurrentData();

    // Emit null cho ID đã bị xóa
    if (item.uid != null && _formulaByIdControllers.containsKey(item.uid)) {
      _formulaByIdControllers[item.uid]!.add(null);
    }

    // Emit data cho các byId streams khác nếu có
    await _emitAllByIdStreams();

    return row;
  }

  // Method để manually trigger stream update
  void refreshStream() {
    _emitCurrentData();
  }

  // Method để manually trigger stream update cho một ID cụ thể
  void refreshStreamById(int id) {
    _emitCurrentDataById(id);
  }

  // Method để cleanup StreamController cho một ID không còn sử dụng
  void disposeStreamById(int id) {
    if (_formulaByIdControllers.containsKey(id)) {
      _formulaByIdControllers[id]!.close();
      _formulaByIdControllers.remove(id);
    }
  }

  @override
  void dispose() {
    _formulaStreamController.close();

    // Đóng tất cả byId streams
    for (final controller in _formulaByIdControllers.values) {
      controller.close();
    }
    _formulaByIdControllers.clear();
  }
}
