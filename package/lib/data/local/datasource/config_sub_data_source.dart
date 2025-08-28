import 'package:package/domain/model/sub_config.dart';

abstract class ConfigSubDataSource {
  Stream<SubConfig> get subStream;

  Future<SubConfig> select();

  Future<int> update(SubConfig item);
}
