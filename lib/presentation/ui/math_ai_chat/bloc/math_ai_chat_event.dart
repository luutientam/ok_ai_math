import 'package:equatable/equatable.dart';
import 'package:flutter_ai_math_2/app.dart';
import 'dart:io';

abstract class MathAiChatEvent extends Equatable {
  const MathAiChatEvent();

  @override
  List<Object?> get props => [];
}

class MathAiChatWatchByMathAiIdEvent extends MathAiChatEvent {
  final int mathAiId;

  const MathAiChatWatchByMathAiIdEvent(this.mathAiId);

  @override
  List<Object?> get props => [mathAiId];
}

class MathAiChatSendMessageEvent extends MathAiChatEvent {
  final int mathAiId;
  final String message;
  final File? image;

  const MathAiChatSendMessageEvent({
    required this.mathAiId,
    required this.message,
    this.image,
  });

  @override
  List<Object?> get props => [mathAiId, message, image];
}

class MathAiChatDeleteMessageEvent extends MathAiChatEvent {
  final MathAiChat message;

  const MathAiChatDeleteMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MathAiChatClearAllEvent extends MathAiChatEvent {
  final int mathAiId;

  const MathAiChatClearAllEvent(this.mathAiId);

  @override
  List<Object?> get props => [mathAiId];
}
