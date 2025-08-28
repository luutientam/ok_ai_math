import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitialState extends CameraState {}

class CameraLoadingState extends CameraState {}

class CameraReadyState extends CameraState {
  final CameraController controller;
  final FlashMode flashMode;
  final bool isFlashAvailable;

  const CameraReadyState(
      this.controller, {
        this.flashMode = FlashMode.off,
        this.isFlashAvailable = false,
      });

  @override
  List<Object?> get props => [flashMode, isFlashAvailable]; // BỎ controller ra khỏi props

  CameraReadyState copyWith({
    CameraController? controller,
    FlashMode? flashMode,
    bool? isFlashAvailable,
  }) {
    return CameraReadyState(
      controller ?? this.controller,
      flashMode: flashMode ?? this.flashMode,
      isFlashAvailable: isFlashAvailable ?? this.isFlashAvailable,
    );
  }
}

class PhotoCapturedState extends CameraState {
  final String imagePath;
  final FlashMode currentFlashMode;

  const PhotoCapturedState(this.imagePath, {this.currentFlashMode = FlashMode.off});

  @override
  List<Object?> get props => [imagePath, currentFlashMode];
}

/// State emitted when user has reached the free capture limit
class CaptureLimitReachedState extends CameraState {
  final int remaining;

  const CaptureLimitReachedState(this.remaining);

  @override
  List<Object?> get props => [remaining];
}

class CameraErrorState extends CameraState {
  final String message;

  const CameraErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// State khi flash mode được cập nhật thành công
class FlashModeUpdatedState extends CameraState {
  final CameraController controller;
  final FlashMode flashMode;
  final String flashModeDisplayName;

  const FlashModeUpdatedState({
    required this.controller,
    required this.flashMode,
    required this.flashModeDisplayName,
  });

  @override
  List<Object?> get props => [flashMode, flashModeDisplayName]; // BỎ controller ra khỏi props
}
