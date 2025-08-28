import 'package:flutter_ai_math_2/app.dart';

class MathUseCase {
  final MathRepository repository;

  MathUseCase({required this.repository});

  Stream<List<Math>> get mathStream => repository.mathStream;

  Stream<Math?> mathStreamById(int id) => repository.mathStreamById(id);

  Future<List<Math>> selectAll() => repository.selectAll();

  Future<Math?> selectById(int id) => repository.selectById(id);

  /// Get all math items sorted by creation date (newest first)
  Future<List<Math>> getAllMath() async {
    final items = await repository.selectAll();
    // Sort by uid in descending order (assuming higher uid means newer)
    items.sort((a, b) => (b.uid ?? 0).compareTo(a.uid ?? 0));
    return items;
  }

  Future<int> insert(Math item) => repository.insert(item);

  Future<int> update(Math item) => repository.update(item);

  Future<int> delete(Math item) => repository.delete(item);

  Future<int> deleteById(int id) => repository.deleteById(id);

  void dispose() => repository.dispose();
}
