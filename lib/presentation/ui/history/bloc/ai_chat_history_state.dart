import 'package:equatable/equatable.dart';
import '../../../../domain/models/math_ai_session_with_first_message.dart';

abstract class AiChatHistoryState extends Equatable {
  const AiChatHistoryState();

  @override
  List<Object?> get props => [];
}

// Initial
class AiChatHistoryInitialState extends AiChatHistoryState {}

// Loading
class AiChatHistoryLoadingState extends AiChatHistoryState {}

// Loaded
class AiChatHistoryLoadedState extends AiChatHistoryState {
  final List<MathAiSessionWithFirstMessage> sessions;
  final Map<int, bool> selectedItems;
  final bool isSelectionMode;

  const AiChatHistoryLoadedState({
    required this.sessions,
    this.selectedItems = const {},
    this.isSelectionMode = false,
  });

  AiChatHistoryLoadedState copyWith({
    List<MathAiSessionWithFirstMessage>? sessions,
    Map<int, bool>? selectedItems,
    bool? isSelectionMode,
  }) {
    return AiChatHistoryLoadedState(
      sessions: sessions ?? this.sessions,
      selectedItems: selectedItems ?? this.selectedItems,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  @override
  List<Object?> get props => [sessions, selectedItems, isSelectionMode];
}

// Error
class AiChatHistoryErrorState extends AiChatHistoryState {
  final String message;

  const AiChatHistoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
