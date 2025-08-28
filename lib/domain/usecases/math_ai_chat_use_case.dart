import 'package:flutter_ai_math_2/app.dart';

class MathAiChatUseCase {
  final MathAiChatRepository repository;

  MathAiChatUseCase({required this.repository});

  Stream<List<MathAiChat>> watchAll() {
    return repository.watchAll();
  }

  Stream<MathAiChat?> watchById(int id) {
    return repository.watchById(id);
  }

  Stream<List<MathAiChat>> watchByMathAiId(int mathAiId) {
    return repository.watchByMathAiId(mathAiId);
  }

  Future<List<MathAiChat>> selectAll() async {
    return await repository.selectAll();
  }

  Future<MathAiChat?> selectById(int id) async {
    return await repository.selectById(id);
  }

  Future<List<MathAiChat>> selectByMathAiId(int mathAiId) async {
    return await repository.selectByMathAiId(mathAiId);
  }

  Future<int> insert(MathAiChat item) async {
    return await repository.insert(item);
  }

  Future<int> update(MathAiChat item) async {
    return await repository.update(item);
  }

  Future<int> delete(MathAiChat item) async {
    return await repository.delete(item);
  }

  Future<List<int>> deleteAll(List<MathAiChat> items) async {
    return await repository.deleteAll(items);
  }

  Future<int> deleteByMathAiId(int mathAiId) async {
    return await repository.deleteByMathAiId(mathAiId);
  }

  void dispose() {
    repository.dispose();
  }
}
