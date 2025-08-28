import 'package:flutter_ai_math_2/app.dart';

import 'math_ai_chat_repository.dart';

class MathAiChatRepositoryImpl implements MathAiChatRepository {
  final MathAiChatDataSource dataSource;

  MathAiChatRepositoryImpl({required this.dataSource});

  @override
  Stream<List<MathAiChat>> watchAll() {
    return dataSource.watchAll();
  }

  @override
  Stream<MathAiChat?> watchById(int id) {
    return dataSource.watchById(id);
  }

  @override
  Stream<List<MathAiChat>> watchByMathAiId(int mathAiId) {
    return dataSource.watchByMathAiId(mathAiId);
  }

  @override
  Future<List<MathAiChat>> selectAll() async {
    return await dataSource.selectAll();
  }

  @override
  Future<MathAiChat?> selectById(int id) async {
    return await dataSource.selectById(id);
  }

  @override
  Future<List<MathAiChat>> selectByMathAiId(int mathAiId) async {
    return await dataSource.selectByMathAiId(mathAiId);
  }

  @override
  Future<int> insert(MathAiChat item) async {
    return await dataSource.insert(item);
  }

  @override
  Future<int> update(MathAiChat item) async {
    return await dataSource.update(item);
  }

  @override
  Future<int> delete(MathAiChat item) async {
    return await dataSource.delete(item);
  }

  @override
  Future<List<int>> deleteAll(List<MathAiChat> items) async {
    return await dataSource.deleteAll(items);
  }

  @override
  Future<int> deleteByMathAiId(int mathAiId) async {
    return await dataSource.deleteByMathAiId(mathAiId);
  }

  @override
  void dispose() {
    dataSource.dispose();
  }
}
