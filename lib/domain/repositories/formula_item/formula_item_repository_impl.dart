import 'package:flutter_ai_math_2/app.dart';

class FormulaItemRepositoryImpl implements FormulaItemRepository {
  final FormulaItemDataSource dataSource;

  FormulaItemRepositoryImpl({required this.dataSource});

  @override
  Stream<List<FormulaItem>> watchAll() {
    return dataSource.watchAll();
  }

  @override
  Stream<FormulaItem?> watchById(int id) {
    return dataSource.watchById(id);
  }

  @override
  Future<List<FormulaItem>> selectAll() async {
    return await dataSource.selectAll();
  }

  @override
  Future<FormulaItem?> selectById(int id) async {
    return await dataSource.selectById(id);
  }

  @override
  Future<int> insert(FormulaItem item) async {
    return await dataSource.insert(item);
  }

  @override
  Future<int> update(FormulaItem item) async {
    return await dataSource.update(item);
  }

  @override
  Future<int> delete(FormulaItem item) async {
    return await dataSource.delete(item);
  }

  @override
  void dispose() {
    dataSource.dispose();
  }
}
