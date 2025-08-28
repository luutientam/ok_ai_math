// setting_state.dart
abstract class SettingState {}

class SettingLoadingState extends SettingState {}

class SettingLoadedState extends SettingState {
  final bool isPremium;

  SettingLoadedState({required this.isPremium});
}

class SettingErrorState extends SettingState {
  final String error;

  SettingErrorState(this.error);
}