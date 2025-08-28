import 'package:flutter_ai_math_2/app.dart';

abstract class FormulaItemDataSource {
  Stream<List<FormulaItem>> watchAll();

  Stream<FormulaItem?> watchById(int id);

  Future<List<FormulaItem>> selectAll();

  Future<FormulaItem?> selectById(int id);

  Future<int> insert(FormulaItem item);

  Future<int> update(FormulaItem item);

  Future<int> delete(FormulaItem item);

  void dispose();
}
