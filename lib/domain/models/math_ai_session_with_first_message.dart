import 'package:flutter_ai_math_2/app.dart';

class MathAiSessionWithFirstMessage {
  final MathAi mathAi;
  final MathAiChat? firstMessage;

  MathAiSessionWithFirstMessage({required this.mathAi, this.firstMessage});

  factory MathAiSessionWithFirstMessage.fromMap(Map<String, dynamic> map) {
    return MathAiSessionWithFirstMessage(
      mathAi: MathAi.fromMap(map),
      firstMessage:
          map['first_message_content'] != null ||
              map['first_message_image_path'] != null ||
              map['first_message_created_at'] != null
          ? MathAiChat(
              uid: map['first_message_uid'] as int?,
              mathAi: map['uid'] as int,
              role: map['first_message_role']?.toString() ?? 'user',
              content: map['first_message_content']?.toString(),
              imagePath: map['first_message_image_path']?.toString(),
              createdAt: DateTime.parse(
                map['first_message_created_at']?.toString() ??
                    DateTime.now().toIso8601String(),
              ),
            )
          : null,
    );
  }
}
