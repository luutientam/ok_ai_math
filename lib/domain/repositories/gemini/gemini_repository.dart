import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';

abstract class GeminiRepository {
  Future<GeminiResponse> analyzeImage(File image, String prompt);

  Future<Math?> analyzeImageToMath(File image);

  Future<GeminiResponse> chat(String prompt);
}
