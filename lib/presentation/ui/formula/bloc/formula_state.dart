import 'package:equatable/equatable.dart';
import 'package:flutter_ai_math_2/app.dart';

abstract class FormulaState extends Equatable {
  const FormulaState();

  @override
  List<Object?> get props => [];
}

class FormulaInitialState extends FormulaState {}

class FormulaLoadingState extends FormulaState {}

class FormulaWatchAllState extends FormulaState {
  final List<Formula> formulas;

  const FormulaWatchAllState(this.formulas);

  Map<String, List<Formula>> get formulasByGroup {
    final Map<String, List<Formula>> map = {};
    for (final formula in formulas) {
      final key = formula.name[0].toUpperCase(); // nhóm theo chữ cái đầu
      map.putIfAbsent(key, () => []).add(formula);
    }
    return map;
  }

  @override
  List<Object?> get props => [formulas];
}

class FormulaWatchByIdState extends FormulaState {
  final Formula? formula;

  const FormulaWatchByIdState(this.formula);

  @override
  List<Object?> get props => [formula];
}

class FormulaUpdatedState extends FormulaState {
  final int rows;

  const FormulaUpdatedState({required this.rows});

  @override
  List<Object?> get props => [rows];
}

class FormulaErrorState extends FormulaState {
  final String message;

  const FormulaErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
