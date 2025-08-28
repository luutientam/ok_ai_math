import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/icons.dart';
import '../../edit/page/edit_page.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';

class BottomBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const BottomBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final paddingBarBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: paddingBarBottom + 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút gallery
          IconButton(
            onPressed: () async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                // Stop camera (and flash) before leaving camera page
                context.read<CameraBloc>().add(CameraStoppedEvent());
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPage(imagePath: picked.path),
                  ),
                );
                // Re-initialize camera after returning from edit
                context.read<CameraBloc>().add(CameraStartedEvent());
              }
            },
            icon: SvgPicture.asset(
              AppIcons.icGallery,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),

          // Nút chụp ảnh
          IconButton(
            onPressed: () {
              final cameraBloc = context.read<CameraBloc>();
              final currentState = cameraBloc.state;
              CameraController? controller;
              if (currentState is CameraReadyState) {
                controller = currentState.controller;
              } else if (currentState is FlashModeUpdatedState) {
                controller = currentState.controller;
              }

              if (controller != null) {
                cameraBloc.add(PhotoCapturedEvent(controller));
              }
            },
            icon: SvgPicture.asset(
              AppIcons.icTakePhoto,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),

          // Nút flash, icon thay đổi theo state flash hiện tại
          BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              // Determine latest flash mode from state when available
              FlashMode effectiveMode;
              CameraController? controller;
              if (state is FlashModeUpdatedState) {
                effectiveMode = state.flashMode;
                controller = state.controller;
              } else if (state is CameraReadyState) {
                effectiveMode = state.flashMode;
                controller = state.controller;
              } else {
                // Fallback to bloc's cached mode
                effectiveMode = context.read<CameraBloc>().currentFlashMode;
              }

              final isFlashOn = effectiveMode == FlashMode.always || effectiveMode == FlashMode.torch;

              return IconButton(
                key: ValueKey(isFlashOn ? 'flash_btn_on' : 'flash_btn_off'),
                onPressed: () {
                  final cameraBloc = context.read<CameraBloc>();
                  if (controller != null) {
                    // Strictly toggle between OFF and ON to avoid cycling
                    if (isFlashOn) {
                      cameraBloc.add(FlashOffEvent(controller!));
                    } else {
                      cameraBloc.add(FlashOnEvent(controller!));
                    }
                  }
                },
                icon: SvgPicture.asset(
                  key: ValueKey(isFlashOn ? 'flash_icon_on' : 'flash_icon_off'),
                  isFlashOn ? AppIcons.icFlashOn : AppIcons.icFlashOff,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
