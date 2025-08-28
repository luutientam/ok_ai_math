import 'package:camera/camera.dart';

abstract class CameraRepository {
  Future<List<CameraDescription>> getAvailableCameras();
  Future<CameraController> initializeCamera(CameraDescription description);
  Future<XFile> takePicture(CameraController controller);
  Future<void> setFlashMode(CameraController controller, FlashMode flashMode);
  Future<FlashMode> getFlashMode(CameraController controller);
  Future<bool> isFlashAvailable(CameraController controller);
}
