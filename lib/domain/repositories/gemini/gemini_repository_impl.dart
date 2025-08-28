import 'dart:convert';
import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';

class GeminiRepositoryImpl implements GeminiRepository {
  final GeminiDataSource datasource;

  GeminiRepositoryImpl(this.datasource);

  @override
  Future<GeminiResponse> analyzeImage(File image, String prompt) async {
    final result = await datasource.analyzeImage(image, prompt);
    return GeminiResponse(result: result);
  }

  @override
  Future<Math?> analyzeImageToMath(File image) async {
    final geminiResponse = await analyzeImage(image, AppPrompts.prompt);

    final raw = geminiResponse.result.trim();
    print("🔍 Gemini raw result:\n$raw");

    try {
      // Tìm và trích JSON trong markdown ```json ... ```
      final match = RegExp(
        r'```json\s*(\{.*?\})\s*```',
        dotAll: true,
      ).firstMatch(raw);

      final String? jsonText = match != null
          ? match.group(1)
          : raw; // fallback nếu không match

      final Map<String, dynamic> json = jsonDecode(jsonText!);

      if (json.containsKey('error')) {
        return null;
      }

      return Math.fromMap(json);
    } catch (e, stack) {
      print("❌ Failed to parse Gemini response: $e\n$stack");
      return null;
    }
  }

  @override
  Future<GeminiResponse> chat(String prompt) async {
    final result = await datasource.chat(prompt);
    return GeminiResponse(result: result);
  }
}
