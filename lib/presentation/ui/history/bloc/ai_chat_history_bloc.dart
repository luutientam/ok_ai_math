import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/history_use_case.dart';
import 'ai_chat_history_event.dart';
import 'ai_chat_history_state.dart';

class AiChatHistoryBloc extends Bloc<AiChatHistoryEvent, AiChatHistoryState> {
  final HistoryUseCase historyUseCase;

  AiChatHistoryBloc({required this.historyUseCase})
      : super(AiChatHistoryInitialState()) {
    // --- Load all sessions ---
    on<AiChatHistoryLoadAllSessionsEvent>((event, emit) async {
      emit(AiChatHistoryLoadingState());
      try {
        final sessions = await historyUseCase.getAllSessionsWithFirstMessage();
        emit(AiChatHistoryLoadedState(sessions: sessions));
      } catch (e) {
        emit(AiChatHistoryErrorState(e.toString()));
      }
    });

    // --- Toggle single selection ---
    on<AiChatHistoryToggleSelection>((event, emit) {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        final newSelected = Map<int, bool>.from(currentState.selectedItems);

        if (event.isSelected) {
          newSelected[event.sessionId] = true;
        } else {
          newSelected.remove(event.sessionId);
        }

        emit(currentState.copyWith(
          selectedItems: newSelected,
          isSelectionMode: newSelected.isNotEmpty,
        ));
      }
    });


    // --- Select or deselect all ---
    on<AiChatHistorySelectAll>((event, emit) {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        final Map<int, bool> newSelected = {};
        for (final s in currentState.sessions) {
          if (s.mathAi.uid != null) {
            newSelected[s.mathAi.uid!] = event.selectAll;
          }
        }
        emit(currentState.copyWith(
          selectedItems: newSelected,
          isSelectionMode: event.selectAll,
        ));
      }
    });

    // --- Delete selected sessions ---
    on<AiChatHistoryDeleteSelected>((event, emit) async {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        try {
          for (final id in event.selectedIds) {
            await historyUseCase.deleteSession(id);
          }
          final sessions = await historyUseCase.getAllSessionsWithFirstMessage();
          emit(currentState.copyWith(
            sessions: sessions,
            selectedItems: {},
            isSelectionMode: false,
          ));
        } catch (e) {
          emit(AiChatHistoryErrorState(e.toString()));
        }
      }
    });

    // --- Delete single session ---
    on<AiChatHistoryDeleteSingle>((event, emit) async {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        try {
          await historyUseCase.deleteSession(event.sessionId);
          final sessions = await historyUseCase.getAllSessionsWithFirstMessage();
          emit(currentState.copyWith(
            sessions: sessions,
            selectedItems: {},
            isSelectionMode: false,
          ));
        } catch (e) {
          emit(AiChatHistoryErrorState(e.toString()));
        }
      }
    });

    // --- Enable selection mode ---
    on<AiChatHistoryEnableSelection>((event, emit) {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        emit(currentState.copyWith(
          isSelectionMode: true,
          selectedItems: {}, // reset chỉ còn rỗng
        ));
      }
    });


    // --- Disable selection mode ---
    on<AiChatHistoryDisableSelection>((event, emit) {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        emit(currentState.copyWith(
          isSelectionMode: false,
          selectedItems: {},
        ));
      }
    });

    // --- Delete all sessions ---
    on<AiChatHistoryDeleteAll>((event, emit) async {
      final currentState = state;
      if (currentState is AiChatHistoryLoadedState) {
        try {
          for (final s in currentState.sessions) {
            if (s.mathAi.uid != null) {
              await historyUseCase.deleteSession(s.mathAi.uid!);
            }
          }
          final sessions = await historyUseCase.getAllSessionsWithFirstMessage();
          emit(currentState.copyWith(
            sessions: sessions,
            isSelectionMode: false,
            selectedItems: {},
          ));
        } catch (e) {
          emit(AiChatHistoryErrorState(e.toString()));
        }
      }
    });
  }
}
