import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';

abstract class ImageInternalRepository {
  Future<SavedImage> save(File imageFile);

  Future<void> delete(String imagePath);
}
