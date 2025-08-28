import 'package:equatable/equatable.dart';
import 'package:flutter_ai_math_2/app.dart';

abstract class FormulaEvent extends Equatable {
  const FormulaEvent();

  @override
  List<Object?> get props => [];
}

class FormulaWatchAllEvent extends FormulaEvent {}

class FormulaWatchByIdEvent extends FormulaEvent {
  final int id;

  const FormulaWatchByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class FormulaUpdateEvent extends FormulaEvent {
  final Formula formula;

  const FormulaUpdateEvent(this.formula);

  @override
  List<Object?> get props => [formula];
}

class FormulaErrorEvent extends FormulaEvent {
  final String message;

  const FormulaErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
