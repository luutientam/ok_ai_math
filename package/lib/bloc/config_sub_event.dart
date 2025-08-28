import 'package:equatable/equatable.dart';
import 'package:package/domain/model/sub_config.dart';

abstract class ConfigSubEvent extends Equatable {
  const ConfigSubEvent();

  @override
  List<Object?> get props => [];
}

class ConfigSubStarted extends ConfigSubEvent {
  const ConfigSubStarted();
}

class ConfigSubUpdateEvent extends ConfigSubEvent {
  final SubConfig subConfig;

  const ConfigSubUpdateEvent(this.subConfig);

  @override
  List<Object?> get props => [subConfig];
}

class StreamData extends ConfigSubEvent {
  final SubConfig? subConfig;

  const StreamData(this.subConfig);

  @override
  List<Object?> get props => [subConfig];
}

class ConfigSubErrorEvent extends ConfigSubEvent {
  final String message;

  const ConfigSubErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class FetchSubscriptionStatusEvent extends ConfigSubEvent {
  const FetchSubscriptionStatusEvent();
}
