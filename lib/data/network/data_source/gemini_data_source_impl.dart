import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_ai_math_2/app.dart';

class GeminiDataSourceImpl implements GeminiDataSource {
  final Dio dio;

  GeminiDataSourceImpl(this.dio);

  @override
  Future<String> analyzeImage(File image, String prompt) async {
    final apiKey = 'AIzaSyC8OtookQj_ifg_VEzX4qPR_4xeinsDhpI';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await dio.post(
      url,
      data: {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inlineData": {"mimeType": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    final text = response.data['candidates'][0]['content']['parts'][0]['text'];
    return text;
  }

  @override
  Future<String> chat(String prompt) async {
    final apiKey = 'AIzaSyC8OtookQj_ifg_VEzX4qPR_4xeinsDhpI';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final response = await dio.post(
      url,
      data: {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    final text = response.data['candidates'][0]['content']['parts'][0]['text'];
    return text;
  }
}
