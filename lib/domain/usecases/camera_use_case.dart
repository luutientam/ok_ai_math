import 'package:camera/camera.dart';
import 'package:flutter_ai_math_2/app.dart';

class CameraUseCase {
  final CameraRepository repository;

  CameraUseCase({required this.repository});

  /// Get list of available cameras
  Future<List<CameraDescription>> getAvailableCameras() =>
      repository.getAvailableCameras();

  /// Initialize camera with the given description
  Future<CameraController> initializeCamera(CameraDescription description) =>
      repository.initializeCamera(description);

  /// Take a picture using the provided camera controller
  Future<XFile> takePicture(CameraController controller) =>
      repository.takePicture(controller);

  /// Toggle flash mode between off, auto, always, and torch
  Future<FlashMode> toggleFlashMode(CameraController controller) async {
    final currentMode = await repository.getFlashMode(controller);
    final nextMode = _getNextFlashMode(currentMode);
    await repository.setFlashMode(controller, nextMode);
    return nextMode;
  }

  /// Set specific flash mode
  Future<void> setFlashMode(
    CameraController controller,
    FlashMode flashMode,
  ) async {
    await repository.setFlashMode(controller, flashMode);
  }

  /// Get current flash mode
  Future<FlashMode> getCurrentFlashMode(CameraController controller) async {
    return await repository.getFlashMode(controller);
  }

  /// Check if flash is available for this camera
  Future<bool> isFlashAvailable(CameraController controller) async {
    return await repository.isFlashAvailable(controller);
  }

  /// Turn flash off
  Future<void> turnFlashOff(CameraController controller) async {
    await repository.setFlashMode(controller, FlashMode.off);
  }

  /// Turn flash on (always)
  Future<void> turnFlashOn(CameraController controller) async {
    await repository.setFlashMode(controller, FlashMode.always);
  }

  /// Set flash to auto mode
  Future<void> setFlashAuto(CameraController controller) async {
    await repository.setFlashMode(controller, FlashMode.auto);
  }

  /// Turn on torch mode (continuous light)
  Future<void> turnTorchOn(CameraController controller) async {
    await repository.setFlashMode(controller, FlashMode.torch);
  }

  /// Get flash mode display name
  String getFlashModeDisplayName(FlashMode flashMode) {
    switch (flashMode) {
      case FlashMode.off:
        return 'Off';
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.always:
        return 'On';
      case FlashMode.torch:
        return 'Torch';
    }
  }

  /// Get next flash mode in cycle: off -> auto -> always -> torch -> off
  FlashMode _getNextFlashMode(FlashMode currentMode) {
    switch (currentMode) {
      case FlashMode.off:
        return FlashMode.auto;
      case FlashMode.auto:
        return FlashMode.always;
      case FlashMode.always:
        return FlashMode.torch;
      case FlashMode.torch:
        return FlashMode.off;
    }
  }
}
