import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_math_2/app.dart';

class FormulaBloc extends Bloc<FormulaEvent, FormulaState> {
  final FormulaUseCase useCase;

  FormulaBloc({required this.useCase}) : super(FormulaInitialState()) {
    print('[FormulaBloc] Created');
    // Đăng ký event handlers theo cách mới
    on<FormulaWatchAllEvent>(_onWatchAll);
    on<FormulaWatchByIdEvent>(_onWatchById);
    on<FormulaUpdateEvent>(_onUpdate);
  }

  /// Watch all formulas
  Future<void> _onWatchAll(
    FormulaWatchAllEvent event,
    Emitter<FormulaState> emit,
  ) async {
    print('[FormulaBloc] _onWatchAll event triggered');
    emit(FormulaLoadingState());
    try {
      await emit.forEach<List<Formula>>(
        useCase.watchAll(),
        onData: (formulas) {
          print(
            '[FormulaBloc] Received formulas list: count=${formulas.length}',
          );
          return FormulaWatchAllState(formulas);
        },
        onError: (error, stackTrace) {
          print('[FormulaBloc] Error in watchAll stream: $error');
          return FormulaErrorState(error.toString());
        },
      );
    } catch (e) {
      print('[FormulaBloc] Exception in _onWatchAll: $e');
      emit(FormulaErrorState(e.toString()));
    }
  }

  /// Watch formula by ID
  Future<void> _onWatchById(
    FormulaWatchByIdEvent event,
    Emitter<FormulaState> emit,
  ) async {
    print('[FormulaBloc] _onWatchById event triggered with id=${event.id}');
    emit(FormulaLoadingState());
    try {
      await emit.forEach<Formula?>(
        useCase.watchById(event.id),
        onData: (formula) {
          print(
            '[FormulaBloc] Received formula by id=${event.id}: ${formula != null ? "found" : "null"}',
          );
          return FormulaWatchByIdState(formula);
        },
        onError: (error, stackTrace) {
          print('[FormulaBloc] Error in watchById stream: $error');
          return FormulaErrorState(error.toString());
        },
      );
    } catch (e) {
      print('[FormulaBloc] Exception in _onWatchById: $e');
      emit(FormulaErrorState(e.toString()));
    }
  }

  /// Update formula
  Future<void> _onUpdate(
    FormulaUpdateEvent event,
    Emitter<FormulaState> emit,
  ) async {
    print(
      '[FormulaBloc] _onUpdate event triggered for formula uid=${event.formula.uid}',
    );
    emit(FormulaLoadingState());
    try {
      final rows = await useCase.update(event.formula);
      print('[FormulaBloc] Updated rows: $rows');
      emit(FormulaUpdatedState(rows: rows));
    } catch (e) {
      print('[FormulaBloc] Exception in _onUpdate: $e');
      emit(FormulaErrorState(e.toString()));
    }
  }
}
