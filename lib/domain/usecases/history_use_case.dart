import 'package:flutter_ai_math_2/app.dart';

class HistoryUseCase {
  final MathAiRepository mathAiRepository;
  final MathAiChatRepository mathAiChatRepository;

  HistoryUseCase({
    required this.mathAiRepository,
    required this.mathAiChatRepository,
  });

  Future<List<MathAiSessionWithFirstMessage>>
  getAllSessionsWithFirstMessage() async {
    try {
      final mathAiList = await mathAiRepository.selectAll();
      final List<MathAiSessionWithFirstMessage> sessions = [];

      for (final mathAi in mathAiList) {
        if (mathAi.uid != null) {
          // Lấy tin nhắn đầu tiên của session này
          final messages = await mathAiChatRepository.selectByMathAiId(
            mathAi.uid!,
          );
          final firstMessage = messages.isNotEmpty ? messages.first : null;

          sessions.add(
            MathAiSessionWithFirstMessage(
              mathAi: mathAi,
              firstMessage: firstMessage,
            ),
          );
        }
      }

      // Sắp xếp theo thời gian tạo (mới nhất trước)
      sessions.sort((a, b) {
        final dateA = DateTime.parse(a.mathAi.createdAt);
        final dateB = DateTime.parse(b.mathAi.createdAt);
        return dateB.compareTo(dateA);
      });

      return sessions;
    } catch (e) {
      throw Exception('Failed to load sessions: $e');
    }
  }

  Future<void> deleteSession(int mathAiId) async {
    try {
      // Xóa tất cả tin nhắn của session
      await mathAiChatRepository.deleteByMathAiId(mathAiId);

      // Xóa session
      final mathAi = await mathAiRepository.selectById(mathAiId);
      if (mathAi != null) {
        await mathAiRepository.delete(mathAi);
      }
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }

  Future<void> clearAllSessions() async {
    try {
      final mathAiList = await mathAiRepository.selectAll();

      for (final mathAi in mathAiList) {
        if (mathAi.uid != null) {
          // Xóa tất cả tin nhắn
          await mathAiChatRepository.deleteByMathAiId(mathAi.uid!);
        }
      }

      // Xóa tất cả sessions
      await mathAiRepository.deleteAll(mathAiList);
    } catch (e) {
      throw Exception('Failed to clear all sessions: $e');
    }
  }
}
