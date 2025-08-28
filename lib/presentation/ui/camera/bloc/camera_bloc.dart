import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../domain/usecases/camera_use_case.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraUseCase cameraUseCase;
  CameraController? _controller;
  FlashMode _currentFlashMode = FlashMode.off;
  bool _isFlashAvailable = false;
  int _remainingFreeCaptures = 3;

  CameraBloc({required this.cameraUseCase}) : super(CameraInitialState()) {
    // Đăng ký các event handlers
    on<CameraStartedEvent>(_onStarted);
    on<CameraStoppedEvent>(_onStopped);
    on<PhotoCapturedEvent>(_onPhotoCaptureRequested);

    // Flash events
    on<FlashToggledEvent>(_onFlashToggled);
    on<FlashModeSetEvent>(_onFlashModeSet);
    on<FlashOffEvent>(_onFlashOff);
    on<FlashOnEvent>(_onFlashOn);
    on<FlashAutoEvent>(_onFlashAuto);
    on<FlashTorchEvent>(_onFlashTorch);
  }

  /// Khởi tạo camera và kiểm tra tính năng flash
  Future<void> _onStarted(CameraStartedEvent event, Emitter<CameraState> emit) async {
    emit(CameraLoadingState());
    try {
      final cameras = await cameraUseCase.getAvailableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = await cameraUseCase.initializeCamera(backCamera);

      // Kiểm tra xem camera có hỗ trợ flash không
      _isFlashAvailable = await cameraUseCase.isFlashAvailable(_controller!);

      // Đặt flash OFF khi khởi động để đồng bộ phần cứng và UI
      if (_isFlashAvailable) {
        await cameraUseCase.turnFlashOff(_controller!);
      }
      _currentFlashMode = FlashMode.off;

      emit(
        CameraReadyState(
          _controller!,
          flashMode: _currentFlashMode,
          isFlashAvailable: _isFlashAvailable,
        ),
      );
    } catch (e) {
      emit(CameraErrorState('Failed to initialize camera: $e'));
    }
  }

  /// Chụp ảnh với flash mode hiện tại
  Future<void> _onPhotoCaptureRequested(PhotoCapturedEvent event, Emitter<CameraState> emit) async {
    // Enforce 3 free captures per app session
    if (_remainingFreeCaptures <= 0) {
      emit(const CaptureLimitReachedState(0));
      return;
    }

    try {
      final image = await cameraUseCase.takePicture(event.controller);
      // Decrement remaining only on success
      _remainingFreeCaptures = (_remainingFreeCaptures - 1).clamp(0, 9999);
      emit(PhotoCapturedState(image.path, currentFlashMode: _currentFlashMode));
    } catch (e) {
      emit(CameraErrorState('Failed to capture photo: $e'));
    }
  }

  /// Dừng camera và giải phóng tài nguyên
  Future<void> _onStopped(CameraStoppedEvent event, Emitter<CameraState> emit) async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isFlashAvailable = false;
      _currentFlashMode = FlashMode.off;
    } catch (_) {}
    emit(CameraInitialState());
  }

  /// Toggle flash mode - chuyển đổi giữa các chế độ flash theo chu kỳ
  /// off -> auto -> always -> torch -> off
  Future<void> _onFlashToggled(FlashToggledEvent event, Emitter<CameraState> emit) async {
    if (!_isFlashAvailable) {
      emit(const CameraErrorState('Flash is not available on this camera'));
      return;
    }

    try {
      final newFlashMode = await cameraUseCase.toggleFlashMode(event.controller);
      _currentFlashMode = newFlashMode;

      final displayName = cameraUseCase.getFlashModeDisplayName(newFlashMode);

      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: newFlashMode,
          flashModeDisplayName: displayName,
        ),
      );
    } catch (e) {
      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: _currentFlashMode,
          flashModeDisplayName: cameraUseCase.getFlashModeDisplayName(_currentFlashMode),
        ),
      );
    }
  }

  /// Set flash mode cụ thể
  Future<void> _onFlashModeSet(FlashModeSetEvent event, Emitter<CameraState> emit) async {
    if (!_isFlashAvailable) {
      emit(const CameraErrorState('Flash is not available on this camera'));
      return;
    }

    try {
      await cameraUseCase.setFlashMode(event.controller, event.flashMode);
      _currentFlashMode = event.flashMode;

      final displayName = cameraUseCase.getFlashModeDisplayName(event.flashMode);

      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: event.flashMode,
          flashModeDisplayName: displayName,
        ),
      );
    } catch (e) {
      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: _currentFlashMode,
          flashModeDisplayName: cameraUseCase.getFlashModeDisplayName(_currentFlashMode),
        ),
      );
    }
  }

  /// Tắt flash
  Future<void> _onFlashOff(FlashOffEvent event, Emitter<CameraState> emit) async {
    try {
      await cameraUseCase.turnFlashOff(event.controller);
      _currentFlashMode = FlashMode.off;

      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: FlashMode.off,
          flashModeDisplayName: 'Off',
        ),
      );
    } catch (e) {
      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: _currentFlashMode,
          flashModeDisplayName: cameraUseCase.getFlashModeDisplayName(_currentFlashMode),
        ),
      );
    }
  }

  /// Bật flash (always on)
  Future<void> _onFlashOn(FlashOnEvent event, Emitter<CameraState> emit) async {
    if (!_isFlashAvailable) {
      emit(const CameraErrorState('Flash is not available on this camera'));
      return;
    }

    try {
      await cameraUseCase.turnFlashOn(event.controller);
      _currentFlashMode = FlashMode.always;

      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: FlashMode.always,
          flashModeDisplayName: 'On',
        ),
      );
    } catch (e) {
      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: _currentFlashMode,
          flashModeDisplayName: cameraUseCase.getFlashModeDisplayName(_currentFlashMode),
        ),
      );
    }
  }

  /// Set flash auto mode
  Future<void> _onFlashAuto(FlashAutoEvent event, Emitter<CameraState> emit) async {
    if (!_isFlashAvailable) {
      emit(const CameraErrorState('Flash is not available on this camera'));
      return;
    }

    try {
      await cameraUseCase.setFlashAuto(event.controller);
      _currentFlashMode = FlashMode.auto;

      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: FlashMode.auto,
          flashModeDisplayName: 'Auto',
        ),
      );
    } catch (e) {
      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: _currentFlashMode,
          flashModeDisplayName: cameraUseCase.getFlashModeDisplayName(_currentFlashMode),
        ),
      );
    }
  }

  /// Bật torch mode (đèn pin liên tục)
  Future<void> _onFlashTorch(FlashTorchEvent event, Emitter<CameraState> emit) async {
    if (!_isFlashAvailable) {
      emit(const CameraErrorState('Flash is not available on this camera'));
      return;
    }

    try {
      await cameraUseCase.turnTorchOn(event.controller);
      _currentFlashMode = FlashMode.torch;

      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: FlashMode.torch,
          flashModeDisplayName: 'Torch',
        ),
      );
    } catch (e) {
      emit(
        FlashModeUpdatedState(
          controller: event.controller,
          flashMode: _currentFlashMode,
          flashModeDisplayName: cameraUseCase.getFlashModeDisplayName(_currentFlashMode),
        ),
      );
    }
  }

  /// Getter để lấy flash mode hiện tại
  FlashMode get currentFlashMode => _currentFlashMode;

  /// Getter để kiểm tra flash có khả dụng không
  bool get isFlashAvailable => _isFlashAvailable;

  /// Getter for remaining free captures
  int get remainingFreeCaptures => _remainingFreeCaptures;

  @override
  Future<void> close() async {
    await _controller?.dispose();
    return super.close();
  }
}
