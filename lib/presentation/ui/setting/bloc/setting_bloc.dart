import 'package:bloc/bloc.dart';
import 'package:flutter_ai_math_2/presentation/ui/setting/bloc/setting_event.dart';
import 'package:flutter_ai_math_2/presentation/ui/setting/bloc/setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingLoadingState()) {
    on<FetchSettings>(_onFetchSettings);
    on<UpgradePremiumPressed>(_onUpgradePremiumPressed);
  }

  void _onFetchSettings(FetchSettings event, Emitter<SettingState> emit) async {
    try {
      // Simulate fetching data, e.g., check user premium status
      await Future.delayed(const Duration(seconds: 1));
      emit(SettingLoadedState(isPremium: false));
    } catch (e) {
      emit(SettingErrorState('Failed to load settings.'));
    }
  }

  void _onUpgradePremiumPressed(UpgradePremiumPressed event, Emitter<SettingState> emit) {
    if (state is SettingLoadedState) {
      final currentState = state as SettingLoadedState;
      // Simulate upgrading to premium
      emit(SettingLoadedState(isPremium: true));
      // In a real app, you would handle payment, API calls, etc. here
    }
  }
}