import 'package:equatable/equatable.dart';

abstract class AiChatHistoryEvent extends Equatable {
  const AiChatHistoryEvent();

  @override
  List<Object?> get props => [];
}
class AiChatHistoryEnableSelection extends AiChatHistoryEvent {}
class AiChatHistoryDisableSelection extends AiChatHistoryEvent {}
class AiChatHistoryDeleteAll extends AiChatHistoryEvent {}

// Load all sessions
class AiChatHistoryLoadAllSessionsEvent extends AiChatHistoryEvent {}

// Delete selected sessions
class AiChatHistoryDeleteSelected extends AiChatHistoryEvent {
  final List<int> selectedIds;

  const AiChatHistoryDeleteSelected(this.selectedIds);

  @override
  List<Object?> get props => [selectedIds];
}

// Toggle selection of single session
class AiChatHistoryToggleSelection extends AiChatHistoryEvent {
  final int sessionId;
  final bool isSelected;

  const AiChatHistoryToggleSelection(this.sessionId, this.isSelected);

  @override
  List<Object?> get props => [sessionId, isSelected];
}

// Select or deselect all
class AiChatHistorySelectAll extends AiChatHistoryEvent {
  final bool selectAll;

  const AiChatHistorySelectAll(this.selectAll);

  @override
  List<Object?> get props => [selectAll];
}

// Delete single session
class AiChatHistoryDeleteSingle extends AiChatHistoryEvent {
  final int sessionId;

  const AiChatHistoryDeleteSingle(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
