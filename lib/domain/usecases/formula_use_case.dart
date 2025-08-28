import 'package:flutter_ai_math_2/app.dart';

class FormulaUseCase {
  final FormulaRepository repository;

  FormulaUseCase({required this.repository});

  Stream<List<Formula>> watchAll() {
    return repository.watchAll();
  }

  Stream<Formula?> watchById(int id) {
    return repository.watchById(id);
  }

  Future<List<Formula>> selectAll() async {
    return await repository.selectAll();
  }

  Future<Formula?> selectById(int id) async {
    return await repository.selectById(id);
  }

  Future<int> insert(Formula item) async {
    return await repository.insert(item);
  }

  Future<int> update(Formula item) async {
    return await repository.update(item);
  }

  Future<int> delete(Formula item) async {
    return await repository.delete(item);
  }

  void dispose() {
    repository.dispose();
  }
}
