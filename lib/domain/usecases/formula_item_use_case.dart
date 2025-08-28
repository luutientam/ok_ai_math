import 'package:flutter_ai_math_2/app.dart';

class FormulaItemUseCase {
  final FormulaItemRepository repository;

  FormulaItemUseCase({required this.repository});

  Stream<List<FormulaItem>> watchAll() {
    return repository.watchAll();
  }

  Stream<FormulaItem?> watchById(int id) {
    return repository.watchById(id);
  }

  Future<List<FormulaItem>> selectAll() async {
    return await repository.selectAll();
  }

  Future<FormulaItem?> selectById(int id) async {
    return await repository.selectById(id);
  }

  Future<int> insert(FormulaItem item) async {
    return await repository.insert(item);
  }

  Future<int> update(FormulaItem item) async {
    return await repository.update(item);
  }

  Future<int> delete(FormulaItem item) async {
    return await repository.delete(item);
  }

  void dispose() {
    repository.dispose();
  }
}
