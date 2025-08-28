import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';

class GeminiUseCase {
  final GeminiRepository repository;

  GeminiUseCase({required this.repository});

  Future<Math?> analyzeImageToMath(File imagePath) async {
    return await repository.analyzeImageToMath(imagePath);
  }
}
