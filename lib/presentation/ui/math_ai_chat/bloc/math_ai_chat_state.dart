import 'package:equatable/equatable.dart';
import 'package:flutter_ai_math_2/app.dart';

abstract class MathAiChatState extends Equatable {
  const MathAiChatState();

  @override
  List<Object?> get props => [];
}

class MathAiChatInitialState extends MathAiChatState {}

class MathAiChatLoadingState extends MathAiChatState {}

class MathAiChatWatchByMathAiIdState extends MathAiChatState {
  final List<MathAiChat> messages;

  const MathAiChatWatchByMathAiIdState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MathAiChatSendingMessageState extends MathAiChatState {
  final List<MathAiChat> messages;

  const MathAiChatSendingMessageState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MathAiChatMessageSentState extends MathAiChatState {
  final List<MathAiChat> messages;

  const MathAiChatMessageSentState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MathAiChatErrorState extends MathAiChatState {
  final String message;

  const MathAiChatErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
