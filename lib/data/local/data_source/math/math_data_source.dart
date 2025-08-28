import 'package:flutter_ai_math_2/app.dart';

abstract class MathDataSource {
  Stream<List<Math>> get mathStream;

  Stream<Math?> mathStreamById(int id);

  Future<List<Math>> selectAll();

  Future<Math?> selectById(int id);

  Future<int> insert(Math item);

  Future<int> update(Math item);

  Future<int> delete(Math item);

  Future<int> deleteById(int id);

  void dispose();
}
