import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Files cho BLoC -----
// setting_event.dart
abstract class SettingEvent {}

class FetchSettings extends SettingEvent {}

class UpgradePremiumPressed extends SettingEvent {}

