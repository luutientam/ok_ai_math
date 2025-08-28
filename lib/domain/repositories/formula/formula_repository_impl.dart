import 'package:flutter_ai_math_2/app.dart';

class FormulaRepositoryImpl implements FormulaRepository {
  final FormulaDataSource dataSource;

  FormulaRepositoryImpl({required this.dataSource});

  @override
  Stream<List<Formula>> watchAll() {
    return dataSource.watchAll();
  }

  @override
  Stream<Formula?> watchById(int id) {
    return dataSource.watchById(id);
  }

  @override
  Future<List<Formula>> selectAll() async {
    return await dataSource.selectAll();
  }

  @override
  Future<Formula?> selectById(int id) async {
    return await dataSource.selectById(id);
  }

  @override
  Future<int> insert(Formula item) async {
    return await dataSource.insert(item);
  }

  @override
  Future<int> update(Formula item) async {
    return await dataSource.update(item);
  }

  @override
  Future<int> delete(Formula item) async {
    return await dataSource.delete(item);
  }

  @override
  void dispose() {
    dataSource.dispose();
  }
}
