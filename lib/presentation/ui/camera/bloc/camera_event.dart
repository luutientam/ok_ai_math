import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class CameraInitializedEvent extends CameraEvent {}

class CameraStartedEvent extends CameraEvent {}

class CameraStoppedEvent extends CameraEvent {}

class CameraErrorEvent extends CameraEvent {
  final String message;

  const CameraErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class PhotoCapturedEvent extends CameraEvent {
  final CameraController controller;

  const PhotoCapturedEvent(this.controller);

  @override
  List<Object?> get props => [controller];
}

/// Event để toggle flash mode (chuyển đổi giữa các chế độ flash)
class FlashToggledEvent extends CameraEvent {
  final CameraController controller;

  const FlashToggledEvent(this.controller);

  @override
  List<Object?> get props => [controller];
}

/// Event để set flash mode cụ thể
class FlashModeSetEvent extends CameraEvent {
  final CameraController controller;
  final FlashMode flashMode;

  const FlashModeSetEvent(this.controller, this.flashMode);

  @override
  List<Object?> get props => [controller, flashMode];
}

/// Event để tắt flash
class FlashOffEvent extends CameraEvent {
  final CameraController controller;

  const FlashOffEvent(this.controller);

  @override
  List<Object?> get props => [controller];
}

/// Event để bật flash (always on)
class FlashOnEvent extends CameraEvent {
  final CameraController controller;

  const FlashOnEvent(this.controller);

  @override
  List<Object?> get props => [controller];
}

/// Event để set flash auto mode
class FlashAutoEvent extends CameraEvent {
  final CameraController controller;

  const FlashAutoEvent(this.controller);

  @override
  List<Object?> get props => [controller];
}

/// Event để bật torch mode (đèn pin liên tục)
class FlashTorchEvent extends CameraEvent {
  final CameraController controller;

  const FlashTorchEvent(this.controller);

  @override
  List<Object?> get props => [controller];
}
