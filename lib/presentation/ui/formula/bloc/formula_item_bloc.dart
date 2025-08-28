import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_math_2/app.dart';

import 'formula_item_event.dart';
import 'formula_item_state.dart';

class FormulaItemBloc extends Bloc<FormulaItemEvent, FormulaItemState> {
  final FormulaItemUseCase useCase;

  StreamSubscription<List<FormulaItem>>? _sub;
  List<FormulaItem> _all = const [];

  FormulaItemBloc({required this.useCase}) : super(FormulaItemLoadingState()) {
    // Always watch all items and keep local cache
    on<FormulaItemWatchByFormulaIdEvent>(_onWatchByFormulaId);
    on<FormulaItemWatchSavedEvent>(_onWatchSaved);
    on<FormulaItemToggleSaveEvent>(_onToggleSave);
    on<FormulaItemAllStreamUpdated>(_onAllStreamUpdated);
    on<FormulaItemStreamError>(_onStreamError);

    _sub = useCase.watchAll().listen(
      (items) {
        _all = items;
        // Emit all by default so UI can filter if it wants
        add(FormulaItemAllStreamUpdated(items));
      },
      onError: (e, st) {
        add(FormulaItemStreamError(e.toString()));
      },
    );

    // kickstart with loading -> will emit when stream arrives
  }

  Future<void> _onAllStreamUpdated(
    FormulaItemAllStreamUpdated event,
    Emitter<FormulaItemState> emit,
  ) async {
    emit(FormulaItemAllState(event.items));
  }

  Future<void> _onStreamError(
    FormulaItemStreamError event,
    Emitter<FormulaItemState> emit,
  ) async {
    emit(FormulaItemErrorState(event.message));
  }

  Future<void> _onWatchByFormulaId(
    FormulaItemWatchByFormulaIdEvent event,
    Emitter<FormulaItemState> emit,
  ) async {
    emit(FormulaItemLoadingState());
    final filtered = _all
        .where((it) => it.formulaId == event.formulaId)
        .toList();
    emit(FormulaItemListState(filtered));
  }

  Future<void> _onWatchSaved(
    FormulaItemWatchSavedEvent event,
    Emitter<FormulaItemState> emit,
  ) async {
    // Emit all so UI can filter saved itself, or we could emit filtered list
    emit(FormulaItemAllState(_all));
  }

  Future<void> _onToggleSave(
    FormulaItemToggleSaveEvent event,
    Emitter<FormulaItemState> emit,
  ) async {
    try {
      final toggled = event.item.copyWith(isSaved: !event.item.isSaved);
      await useCase.update(toggled);
      // After update, watchAll stream will push new items; no manual emit needed
    } catch (e) {
      emit(FormulaItemErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    useCase.dispose();
    return super.close();
  }
}
