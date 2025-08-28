import 'package:package/data/local/datasource/config_sub_data_source.dart';
import 'package:package/domain/model/sub_config.dart';
import 'package:package/domain/repository/config_sub_repository.dart';

class ConfigSubRepositoryImpl implements ConfigSubRepository {
  final ConfigSubDataSource dataSource;

  ConfigSubRepositoryImpl({required this.dataSource});

  @override
  Stream<SubConfig> get subStream => dataSource.subStream;

  @override
  Future<SubConfig> select() => dataSource.select();

  @override
  Future<int> update(SubConfig item) => dataSource.update(item);
}
