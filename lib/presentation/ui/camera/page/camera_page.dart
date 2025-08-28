  import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/icons.dart';
import '../../edit/page/edit_page.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/bottom_bar_widget.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraState? state;

  @override
  void initState() {
    super.initState();
    // Initialize camera or any other setup if needed
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CameraBloc, CameraState>(
      listener: (context, state) {
        // Handle state changes from BLoC
        if (state is CameraLoadingState) {
          // Show loading indicator
          this.state = null;
          setState(() {});
        } else if (state is CameraReadyState) {
          // Camera is ready, update UI
          this.state = state;
          setState(() {});
          state.controller;
        } else if (state is PhotoCapturedState) {
          // Stop camera (and flash) before leaving the page
          context.read<CameraBloc>().add(CameraStoppedEvent());
          // Navigate to EditPage with captured image path.
          // EditPage will pushReplacement to SolvePage directly, so we just wait until user finishes SolvePage.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPage(imagePath: state.imagePath),
            ),
          ).then((_) {
            // Re-initialize camera to return to Ready state after coming back from SolvePage
            if (mounted) {
              context.read<CameraBloc>().add(CameraStartedEvent());
            }
          });
        } else if (state is CaptureLimitReachedState) {
          // Show dialog notifying the user that free captures are exhausted
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: const Color(0xFF0A0D12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(width: 8),
                          Text(
                            'Error',
                            style: TextStyle(color: Color(0xFFFDFDFD), fontSize: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                      const Text(
                        'You\'ve used all your free scans. Upgrade to get more scans!',
                        style: TextStyle(color: Color(0xFFFDFDFD), fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFFF5F5F5),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Okay',
                          style: TextStyle(
                            color: Color(0xFFDB1616),
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).then((_) {
            if (!mounted) return;
            final bloc = context.read<CameraBloc>();
            final s = bloc.state;
            if (s is! CameraReadyState && s is! FlashModeUpdatedState) {
              bloc.add(CameraStartedEvent());
            }
          });
        } else if (state is CameraErrorState) {
          // Không xóa preview; chỉ hiển thị thông báo lỗi nhẹ
          final message = state.message ?? 'Camera error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          // Any other state (e.g., initial) should clear preview
          this.state = null;
          setState(() {});
        }
      },
      child: _buildCameraPage(context),
    );
  }

  Widget _buildCameraPage(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Gửi event dừng camera
        context.read<CameraBloc>().add(CameraStoppedEvent());
        // Cho phép thoát màn hình
        return true;
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraPreview(context),
            Positioned(top: 0, left: 0, right: 0, child: AppBarWidget()),
            _buildCenterIcons(context),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 130,
              child: BlocBuilder<CameraBloc, CameraState>(
                builder: (context, state) {
                  final remaining = context.read<CameraBloc>().remainingFreeCaptures;
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '$remaining free scans left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(bottom: 0, left: 0, right: 0, child: BottomBarWidget()),
          ],
        ),
      ),
    );
  }


  Widget _buildCameraPreview(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      // Giữ nguyên preview khi có CameraErrorState (không rebuild về trống)
      buildWhen: (prev, curr) {
        // Đừng rebuild khi hiển thị dialog để camera vẫn chạy và preview còn hiển thị
        if (curr is CameraErrorState) return false;
        if (curr is CaptureLimitReachedState) return false;
        return prev.runtimeType != curr.runtimeType ||
            (curr is CameraReadyState || curr is FlashModeUpdatedState);
      },
      builder: (context, blocState) {
        if (blocState is CameraReadyState) {
          return CameraPreview(blocState.controller);
        } else if (blocState is FlashModeUpdatedState) {
          return CameraPreview(blocState.controller);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCenterIcons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: SizedBox(
        width: screenWidth - 30,// kích thước khung ngắm
        height: 160,
        child: Stack(
          children: [
            // Góc trên trái
            Positioned(
              top: 0,
              left: 0,
              child: SvgPicture.asset(
                AppIcons.icCropTopLeft,
                width: 32,
                height: 32,
              ),
            ),

            // Góc trên phải
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                AppIcons.icCropTopRight,
                width: 32,
                height: 32,
              ),
            ),

            // Góc dưới trái
            Positioned(
              bottom: 0,
              left: 0,
              child: SvgPicture.asset(
                AppIcons.icCropBottomLeft,
                width: 32,
                height: 32,
              ),
            ),

            // Góc dười phải
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                AppIcons.icCropBottomRight,
                width: 32,
                height: 32,
              ),
            ),

            // Text nằm gọn bên trong 4 góc
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: const Center(
                child: Text(
                  'Center your question on the screen for the best experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0A0D12),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure camera is stopped when leaving this page
    if (mounted) {
      context.read<CameraBloc>().add(CameraStoppedEvent());
    }
    super.dispose();
  }
}
