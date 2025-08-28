import 'package:flutter_ai_math_2/app.dart';

abstract class MathAiChatRepository {
  Stream<List<MathAiChat>> watchAll();

  Stream<MathAiChat?> watchById(int id);

  Stream<List<MathAiChat>> watchByMathAiId(int mathAiId);

  Future<List<MathAiChat>> selectAll();

  Future<MathAiChat?> selectById(int id);

  Future<List<MathAiChat>> selectByMathAiId(int mathAiId);

  Future<int> insert(MathAiChat item);

  Future<int> update(MathAiChat item);

  Future<int> delete(MathAiChat item);

  Future<List<int>> deleteAll(List<MathAiChat> items);

  Future<int> deleteByMathAiId(int mathAiId);

  void dispose();
}
