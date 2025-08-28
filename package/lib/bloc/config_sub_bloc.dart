import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package/bloc/config_sub_event.dart';
import 'package:package/bloc/config_sub_state.dart';
import 'package:package/domain/usecases/config_sub_use_case.dart';
import 'package:package/domain/usecases/fetch_sub_use_case.dart';
import 'package:package/domain/model/sub_config.dart';

class ConfigSubBloc extends Bloc<ConfigSubEvent, ConfigSubState> {
  final ConfigSubUseCase configSubUseCase;
  final FetchSubUseCase fetchSubUseCase;
  StreamSubscription? _subscription;

  ConfigSubBloc({required this.configSubUseCase, required this.fetchSubUseCase})
    : super(ConfigSubInitial()) {
    on<ConfigSubStarted>(_onStarted);
    on<ConfigSubUpdateEvent>(_onUpdated);
    on<FetchSubscriptionStatusEvent>(_onFetchSubscriptionStatus);

    // Automatically start listening to stream when bloc is created
    add(ConfigSubStarted());
  }

  void _onStarted(ConfigSubStarted event, Emitter<ConfigSubState> emit) async {
    emit(ConfigSubLoading());

    _subscription?.cancel();

    await emit.forEach<SubConfig>(
      configSubUseCase.subStream,
      onData: (subConfig) => ConfigSubLoaded(subConfig: subConfig),
      onError: (error, stackTrace) => ConfigSubErrorState(message: error.toString()),
    );
  }

  Future<void> _onUpdated(ConfigSubUpdateEvent event, Emitter<ConfigSubState> emit) async {
    emit(ConfigSubLoading());
    try {
      final updatedCount = await configSubUseCase.update(event.subConfig);
      if (updatedCount > 0) {
        emit(ConfigSubLoaded(subConfig: event.subConfig));
      } else {
        emit(ConfigSubErrorState(message: 'Update failed.'));
      }
    } catch (e) {
      emit(ConfigSubErrorState(message: e.toString()));
    }
  }

  Future<void> _onFetchSubscriptionStatus(
    FetchSubscriptionStatusEvent event,
    Emitter<ConfigSubState> emit,
  ) async {
    try {
      final subscriptionStatus = await fetchSubUseCase.execute();
      emit(SubscriptionStatusLoaded(subscriptionStatus: subscriptionStatus));
    } catch (e) {
      emit(ConfigSubErrorState(message: 'Failed to fetch subscription status: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
