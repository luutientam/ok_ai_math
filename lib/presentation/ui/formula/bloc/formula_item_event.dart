import 'package:equatable/equatable.dart';
import 'package:flutter_ai_math_2/app.dart';

abstract class FormulaItemEvent extends Equatable {
  const FormulaItemEvent();

  @override
  List<Object?> get props => [];
}

class FormulaItemWatchByFormulaIdEvent extends FormulaItemEvent {
  final int formulaId;

  const FormulaItemWatchByFormulaIdEvent(this.formulaId);

  @override
  List<Object?> get props => [formulaId];
}

class FormulaItemWatchSavedEvent extends FormulaItemEvent {}

class FormulaItemToggleSaveEvent extends FormulaItemEvent {
  final FormulaItem item;

  const FormulaItemToggleSaveEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// Internal events for stream updates
class FormulaItemAllStreamUpdated extends FormulaItemEvent {
  final List<FormulaItem> items;

  const FormulaItemAllStreamUpdated(this.items);

  @override
  List<Object?> get props => [items];
}

class FormulaItemStreamError extends FormulaItemEvent {
  final String message;

  const FormulaItemStreamError(this.message);

  @override
  List<Object?> get props => [message];
}
