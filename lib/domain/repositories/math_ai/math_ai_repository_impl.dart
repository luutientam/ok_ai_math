import 'package:flutter_ai_math_2/app.dart';

import 'math_ai_repository.dart';

class MathAiRepositoryImpl implements MathAiRepository {
  final MathAiDataSource dataSource;

  MathAiRepositoryImpl({required this.dataSource});

  @override
  Stream<List<MathAi>> watchAll() {
    return dataSource.watchAll();
  }

  @override
  Stream<MathAi?> watchById(int id) {
    return dataSource.watchById(id);
  }

  @override
  Future<List<MathAi>> selectAll() async {
    return await dataSource.selectAll();
  }

  @override
  Future<MathAi?> selectById(int id) async {
    return await dataSource.selectById(id);
  }

  @override
  Future<int> insert(MathAi item) async {
    return await dataSource.insert(item);
  }

  @override
  Future<int> update(MathAi item) async {
    return await dataSource.update(item);
  }

  @override
  Future<int> delete(MathAi item) async {
    return await dataSource.delete(item);
  }

  @override
  Future<List<int>> deleteAll(List<MathAi> items) async {
    return await dataSource.deleteAll(items);
  }

  @override
  void dispose() {
    dataSource.dispose();
  }
}
