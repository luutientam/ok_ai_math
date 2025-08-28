import 'package:flutter_ai_math_2/app.dart';

class MathAiUseCase {
  final MathAiRepository repository;

  MathAiUseCase({required this.repository});

  Stream<List<MathAi>> watchAll() {
    return repository.watchAll();
  }

  Stream<MathAi?> watchById(int id) {
    return repository.watchById(id);
  }

  Future<List<MathAi>> selectAll() async {
    return await repository.selectAll();
  }

  Future<MathAi?> selectById(int id) async {
    return await repository.selectById(id);
  }

  Future<int> insert(MathAi item) async {
    return await repository.insert(item);
  }

  Future<int> update(MathAi item) async {
    return await repository.update(item);
  }

  Future<int> delete(MathAi item) async {
    return await repository.delete(item);
  }

  Future<List<int>> deleteAll(List<MathAi> items) async {
    return await repository.deleteAll(items);
  }

  void dispose() {
    repository.dispose();
  }
}
