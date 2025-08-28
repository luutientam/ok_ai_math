import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';
import 'package:path_provider/path_provider.dart';

class ImageInternalDataSourceImpl implements ImageInternalDataSource {
  @override
  Future<String> save(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedPath = '${dir.path}/$fileName';

    final savedFile = await imageFile.copy(savedPath);
    return savedFile.path;
  }

  @override
  Future<void> delete(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
