import 'dart:io';

import 'package:flutter_ai_math_2/app.dart';

class ImageInternalRepositoryImpl implements ImageInternalRepository {
  final ImageInternalDataSource _imageInternalDataSource;

  ImageInternalRepositoryImpl(this._imageInternalDataSource);

  @override
  Future<SavedImage> save(File imageFile) async {
    final path = await _imageInternalDataSource.save(imageFile);
    return SavedImage(path);
  }

  @override
  Future<void> delete(String imagePath) async {
    await _imageInternalDataSource.delete(imagePath);
  }
}
