import 'dart:io';

abstract class GeminiDataSource {
  Future<String> analyzeImage(File image, String prompt);
  Future<String> chat(String prompt);
}
