import 'dart:io';

abstract class ImageInternalDataSource {
  Future<String> save(File imageFile);

  Future<void> delete(String imagePath);
}