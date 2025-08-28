import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_math_2/app.dart';

import 'math_ai_chat_event.dart';
import 'math_ai_chat_state.dart';

class MathAiChatBloc extends Bloc<MathAiChatEvent, MathAiChatState> {
  final MathAiChatUseCase useCase;
  final GeminiRepository geminiRepository;

  MathAiChatBloc({required this.useCase, required this.geminiRepository})
    : super(MathAiChatInitialState()) {
    on<MathAiChatWatchByMathAiIdEvent>(_onWatchByMathAiId);
    on<MathAiChatSendMessageEvent>(_onSendMessage);
    on<MathAiChatDeleteMessageEvent>(_onDeleteMessage);
    on<MathAiChatClearAllEvent>(_onClearAll);
  }

  Future<void> _onWatchByMathAiId(
    MathAiChatWatchByMathAiIdEvent event,
    Emitter<MathAiChatState> emit,
  ) async {
    print(
      '[MathAiChatBloc] _onWatchByMathAiId event triggered with mathAiId=${event.mathAiId}',
    );
    emit(MathAiChatLoadingState());
    try {
      await emit.forEach<List<MathAiChat>>(
        useCase.watchByMathAiId(event.mathAiId),
        onData: (messages) {
          return MathAiChatWatchByMathAiIdState(messages);
        },
        onError: (error, stackTrace) {
          return MathAiChatErrorState(error.toString());
        },
      );
    } catch (e) {
      emit(MathAiChatErrorState(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    MathAiChatSendMessageEvent event,
    Emitter<MathAiChatState> emit,
  ) async {
    try {
      // Get current messages
      final currentMessages = await useCase.selectByMathAiId(event.mathAiId);

      // Create user message
      final userMessage = MathAiChat(
        mathAi: event.mathAiId,
        role: 'user',
        content: event.message,
        imagePath: event.image?.path,
        createdAt: DateTime.now(),
      );

      // Insert user message
      await useCase.insert(userMessage);

      // Update UI to show sending state
      final updatedMessages = [...currentMessages, userMessage];
      emit(MathAiChatSendingMessageState(updatedMessages));

      // Prepare prompt for AI
      String prompt = event.message;

      // Get AI response
      String aiResponse;
      if (event.image != null) {
        // Có hình ảnh - sử dụng analyzeImage
        prompt = event.message.isEmpty
            ? "Analyze this mathematical image and solve the problem step by step"
            : "Analyze this mathematical image and solve the problem step by step: $prompt";

        final geminiResponse = await geminiRepository.analyzeImage(
          event.image!,
          prompt,
        );
        aiResponse = geminiResponse.result;
      } else {
        // Chỉ có text - sử dụng chat API
        if (event.message.isEmpty) {
          aiResponse =
              "Please provide a question or problem for me to help you with.";
        } else {
          prompt = "Solve this math problem step by step: $prompt";
          final geminiResponse = await geminiRepository.chat(prompt);
          aiResponse = geminiResponse.result;
        }
      }

      // Create AI response message
      final aiMessage = MathAiChat(
        mathAi: event.mathAiId,
        role: 'assistant',
        content: aiResponse,
        createdAt: DateTime.now(),
      );

      // Insert AI response
      await useCase.insert(aiMessage);

      // The stream will automatically update with new messages
      print('[MathAiChatBloc] Message sent successfully');
    } catch (e) {
      print('[MathAiChatBloc] Error sending message: $e');
      emit(MathAiChatErrorState('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMessage(
    MathAiChatDeleteMessageEvent event,
    Emitter<MathAiChatState> emit,
  ) async {
    try {
      await useCase.delete(event.message);
      print('[MathAiChatBloc] Message deleted successfully');
    } catch (e) {
      print('[MathAiChatBloc] Error deleting message: $e');
      emit(MathAiChatErrorState('Failed to delete message: ${e.toString()}'));
    }
  }

  Future<void> _onClearAll(
    MathAiChatClearAllEvent event,
    Emitter<MathAiChatState> emit,
  ) async {
    try {
      await useCase.deleteByMathAiId(event.mathAiId);
      print('[MathAiChatBloc] All messages cleared successfully');
    } catch (e) {
      print('[MathAiChatBloc] Error clearing messages: $e');
      emit(MathAiChatErrorState('Failed to clear messages: ${e.toString()}'));
    }
  }
}
