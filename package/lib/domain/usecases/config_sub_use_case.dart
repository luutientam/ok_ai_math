import 'package:package/domain/model/sub_config.dart';
import 'package:package/domain/repository/config_sub_repository.dart';

class ConfigSubUseCase {
  final ConfigSubRepository repository;

  ConfigSubUseCase({required this.repository});

  Stream<SubConfig> get subStream => repository.subStream;

  Future<SubConfig> select() => repository.select();

  Future<int> update(SubConfig item) => repository.update(item);
}
