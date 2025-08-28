import 'package:equatable/equatable.dart';
import 'package:package/domain/model/sub_config.dart';
import 'package:package/domain/model/subscription_status.dart';

abstract class ConfigSubState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConfigSubInitial extends ConfigSubState {}

class ConfigSubLoading extends ConfigSubState {}

class ConfigSubLoaded extends ConfigSubState {
  final SubConfig subConfig;
  final SubscriptionStatus? subscriptionStatus;

  ConfigSubLoaded({required this.subConfig, this.subscriptionStatus});

  @override
  List<Object?> get props => [subConfig, subscriptionStatus];
}

class ConfigSubErrorState extends ConfigSubState {
  final String message;

  ConfigSubErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubscriptionStatusLoaded extends ConfigSubState {
  final SubscriptionStatus subscriptionStatus;

  SubscriptionStatusLoaded({required this.subscriptionStatus});

  @override
  List<Object?> get props => [subscriptionStatus];
}
