import 'package:camera/camera.dart';
import 'package:flutter_ai_math_2/app.dart';

class CameraRepositoryImpl implements CameraRepository {
  @override
  Future<List<CameraDescription>> getAvailableCameras() => availableCameras();

  @override
  Future<CameraController> initializeCamera(
    CameraDescription description,
  ) async {
    final controller = CameraController(description, ResolutionPreset.high);
    await controller.initialize();
    return controller;
  }

  @override
  Future<XFile> takePicture(CameraController controller) =>
      controller.takePicture();

  @override
  Future<void> setFlashMode(
    CameraController controller,
    FlashMode flashMode,
  ) async {
    try {
      await controller.setFlashMode(flashMode);
    } catch (e) {
      throw CameraException(
        'SET_FLASH_MODE_FAILED',
        'Failed to set flash mode: $e',
      );
    }
  }

  @override
  Future<FlashMode> getFlashMode(CameraController controller) async {
    try {
      return controller.value.flashMode;
    } catch (e) {
      throw CameraException(
        'GET_FLASH_MODE_FAILED',
        'Failed to get flash mode: $e',
      );
    }
  }

  @override
  Future<bool> isFlashAvailable(CameraController controller) async {
    try {
      // Check if the camera description has flash available
      final description = controller.description;

      // For most cameras, if it's a back camera, it usually has flash
      // Front cameras typically don't have flash
      if (description.lensDirection == CameraLensDirection.back) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // If there's an error, assume flash is not available
      return false;
    }
  }
}
