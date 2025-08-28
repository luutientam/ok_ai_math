import 'package:flutter_ai_math_2/app.dart';

abstract class MathAiDataSource {
  Stream<List<MathAi>> watchAll();

  Stream<MathAi?> watchById(int id);

  Future<List<MathAi>> selectAll();

  Future<MathAi?> selectById(int id);

  Future<int> insert(MathAi item);

  Future<int> update(MathAi item);

  Future<int> delete(MathAi item);

  Future<List<int>> deleteAll(List<MathAi> items);

  void dispose();
}