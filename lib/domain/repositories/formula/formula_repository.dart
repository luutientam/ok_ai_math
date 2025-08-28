import 'package:flutter_ai_math_2/app.dart';

abstract class FormulaRepository {
  Stream<List<Formula>> watchAll();

  Stream<Formula?> watchById(int id);

  Future<List<Formula>> selectAll();

  Future<Formula?> selectById(int id);

  Future<int> insert(Formula item);

  Future<int> update(Formula item);

  Future<int> delete(Formula item);

  void dispose();
}
