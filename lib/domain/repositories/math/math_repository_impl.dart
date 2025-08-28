import 'dart:async';

import 'package:flutter_ai_math_2/app.dart';

class MathRepositoryImpl implements MathRepository {
  final MathDataSource dataSource;

  MathRepositoryImpl({required this.dataSource});

  @override
  Stream<List<Math>> get mathStream => dataSource.mathStream;

  @override
  Stream<Math?> mathStreamById(int id) => dataSource.mathStreamById(id);
  @override
  Future<List<Math>> selectAll() async {
    return await dataSource.selectAll();
  }

  @override
  Future<Math?> selectById(int id) async {
    return await dataSource.selectById(id);
  }

  @override
  Future<int> insert(Math item) async {
    return await dataSource.insert(item);
  }

  @override
  Future<int> update(Math item) async {
    return await dataSource.update(item);
  }

  @override
  Future<int> delete(Math item) async {
    return await dataSource.delete(item);
  }

  @override
  Future<int> deleteById(int id) async {
    return await dataSource.deleteById(id);
  }

  @override
  void dispose() {
    dataSource.dispose();
  }
}
