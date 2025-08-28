import 'dart:async';
import 'package:flutter_ai_math_2/presentation/ui/history/bloc/take_photo_history_event.dart';
import 'package:flutter_ai_math_2/presentation/ui/history/bloc/take_photo_history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/math_use_case.dart';

class TakePhotoHistoryBloc extends Bloc<TakePhotoHistoryEvent, TakePhotoHistoryState> {
  final MathUseCase mathUseCase;
  StreamSubscription? _mathSubscription;

  TakePhotoHistoryBloc({required this.mathUseCase}) : super(const TakePhotoHistoryInitial()) {
    on<LoadTakePhotoHistory>(_onLoadTakePhotoHistory);
    on<DeleteTakePhotoHistoryItem>(_onDeleteTakePhotoHistoryItem);
    on<DeleteSelectedTakePhotoHistoryItems>(_onDeleteSelectedItems);
    on<ToggleTakePhotoHistorySelection>(_onToggleSelection);
    on<ToggleSelectionMode>(_onToggleSelectionMode);
    on<SelectAllTakePhotoHistoryItems>(_onSelectAllItems);
    on<ToggleSelectByDate>(_onToggleSelectByDate);
    on<DeleteAllTakePhotoHistoryItems>(_onDeleteAllItems);
    // Subscribe to math changes
    _mathSubscription = mathUseCase.mathStream.listen((mathList) {
      if (state is TakePhotoHistoryLoaded) {
        add(const LoadTakePhotoHistory());
      }
    });
  }

  @override
  Future<void> close() {
    _mathSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTakePhotoHistory(
      LoadTakePhotoHistory event,
      Emitter<TakePhotoHistoryState> emit,
      ) async {
    try {
      emit(TakePhotoHistoryLoading(takePhotoHistoryItems: state is TakePhotoHistoryLoaded
          ? (state as TakePhotoHistoryLoaded).takePhotoHistoryItems
          : const []));

      final items = await mathUseCase.getAllMath();
      emit(TakePhotoHistoryLoaded(
        takePhotoHistoryItems: items,
        selectedItems: state is TakePhotoHistoryLoaded
            ? (state as TakePhotoHistoryLoaded).selectedItems
            : const {},
        isSelectionMode: state is TakePhotoHistoryLoaded
            ? (state as TakePhotoHistoryLoaded).isSelectionMode
            : false,
      ));
    } catch (e) {
      emit(TakePhotoHistoryError('Failed to load takePhotoHistory: $e'));
      // Revert to previous state if possible
      if (state is TakePhotoHistoryLoading) {
        final previousItems = (state as TakePhotoHistoryLoading).takePhotoHistoryItems;
        if (previousItems.isNotEmpty) {
          emit(TakePhotoHistoryLoaded(takePhotoHistoryItems: previousItems));
        }
      }
    }
  }

  Future<void> _onDeleteTakePhotoHistoryItem(
      DeleteTakePhotoHistoryItem event,
      Emitter<TakePhotoHistoryState> emit,
      ) async {
    if (state is! TakePhotoHistoryLoaded) return;

    final currentState = state as TakePhotoHistoryLoaded;
    try {
      await mathUseCase.deleteById(event.id);
      // The stream subscription will trigger a reload
    } catch (e) {
      emit(TakePhotoHistoryError('Failed to delete item: $e'));
      emit(currentState);
    }
  }

  Future<void> _onDeleteSelectedItems(
      DeleteSelectedTakePhotoHistoryItems event,
      Emitter<TakePhotoHistoryState> emit,
      ) async {
    if (state is! TakePhotoHistoryLoaded) return;

    final currentState = state as TakePhotoHistoryLoaded;
    try {
      for (final id in currentState.selectedItems.keys) {
        await mathUseCase.deleteById(id);
      }
      // The stream subscription will trigger a reload
    } catch (e) {
      emit(TakePhotoHistoryError('Failed to delete selected items: $e'));
      emit(currentState);
    }
  }

  void _onToggleSelection(
      ToggleTakePhotoHistorySelection event,
      Emitter<TakePhotoHistoryState> emit,
      ) {
    if (state is! TakePhotoHistoryLoaded) return;

    final currentState = state as TakePhotoHistoryLoaded;
    final updatedSelectedItems = Map<int, bool>.from(currentState.selectedItems);

    if (event.isSelected) {
      updatedSelectedItems[event.item.uid!] = true;
    } else {
      updatedSelectedItems.remove(event.item.uid);
    }

    emit(
      currentState.copyWith(
        selectedItems: updatedSelectedItems,
        isSelectionMode: updatedSelectedItems.isNotEmpty || currentState.isSelectionMode,
      ),
    );
  }

  void _onToggleSelectionMode(
      ToggleSelectionMode event,
      Emitter<TakePhotoHistoryState> emit,
      ) {
    if (state is! TakePhotoHistoryLoaded) return;

    final currentState = state as TakePhotoHistoryLoaded;
    emit(
      currentState.copyWith(
        isSelectionMode: event.enable,
        selectedItems: event.enable ? currentState.selectedItems : const {},
      ),
    );
  }

  void _onSelectAllItems(
      SelectAllTakePhotoHistoryItems event,
      Emitter<TakePhotoHistoryState> emit,
      ) {
    if (state is! TakePhotoHistoryLoaded) return;

    final currentState = state as TakePhotoHistoryLoaded;

    final updatedSelectedItems = event.selectAll
        ? {for (final item in currentState.takePhotoHistoryItems) item.uid!: true}
        : <int, bool>{}; // bỏ chọn hết

    emit(
      currentState.copyWith(
        selectedItems: updatedSelectedItems,
        isSelectionMode: event.selectAll || currentState.isSelectionMode,
      ),
    );
  }

  void _onToggleSelectByDate(
      ToggleSelectByDate event,
      Emitter<TakePhotoHistoryState> emit,
      ) {
    if (state is! TakePhotoHistoryLoaded) return;
    final currentState = state as TakePhotoHistoryLoaded;

    final updatedSelected = Map<int, bool>.from(currentState.selectedItems);

    // lọc tất cả item có cùng ngày
    for (final item in currentState.takePhotoHistoryItems) {
      final itemDate = DateTime(
        item.createdAt!.year,
        item.createdAt!.month,
        item.createdAt!.day,
      );
      final targetDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (itemDate == targetDate) {
        if (event.isSelected) {
          updatedSelected[item.uid!] = true;
        } else {
          updatedSelected.remove(item.uid!);
        }
      }
    }

    emit(
      currentState.copyWith(
        selectedItems: updatedSelected,
        isSelectionMode: updatedSelected.isNotEmpty,
      ),
    );
  }

  Future<void> _onDeleteAllItems(
      DeleteAllTakePhotoHistoryItems event,
      Emitter<TakePhotoHistoryState> emit,
      ) async {
    if (state is! TakePhotoHistoryLoaded) return;

    final currentState = state as TakePhotoHistoryLoaded;
    try {
      for (final item in currentState.takePhotoHistoryItems) {
        await mathUseCase.deleteById(item.uid!);
      }
      // Stream subscription sẽ tự động trigger LoadTakePhotoHistory
    } catch (e) {
      emit(TakePhotoHistoryError('Failed to delete all items: $e'));
      emit(currentState);
    }
  }
}