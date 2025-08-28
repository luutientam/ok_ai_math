import 'package:equatable/equatable.dart';
import 'package:flutter_ai_math_2/app.dart';

abstract class FormulaItemState extends Equatable {
  const FormulaItemState();

  @override
  List<Object?> get props => [];
}

class FormulaItemLoadingState extends FormulaItemState {}

class FormulaItemAllState extends FormulaItemState {
  final List<FormulaItem> allItems;

  const FormulaItemAllState(this.allItems);

  @override
  List<Object?> get props => [allItems];
}

class FormulaItemListState extends FormulaItemState {
  final List<FormulaItem> items;

  const FormulaItemListState(this.items);

  @override
  List<Object?> get props => [items];
}

class FormulaItemErrorState extends FormulaItemState {
  final String message;

  const FormulaItemErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
