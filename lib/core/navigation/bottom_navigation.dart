import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter_ai_math_2/app.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final NotchBottomBarController notchController;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.notchController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedNotchBottomBar(
      durationInMilliSeconds: 500,
      notchBottomBarController: notchController,
      onTap: (index) {
        onTap(index);
        notchController.jumpTo(index);
      },
      kIconSize: 24,
      kBottomRadius: 16,
      color: const Color(0xFF181D27),
      notchColor: const Color(0xFF181D27),
      showLabel: true,
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: SvgPicture.asset(
            AppIcons.icHome,
            color: const Color(0xFF9E9E9E),
            width: 24,
          ),
          activeItem: SvgPicture.asset(
            AppIcons.icHome,
            color: Colors.red,
            width: 24,
          ),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: SvgPicture.asset(
            AppIcons.icCameraNavigation,
            color: const Color(0xFF9E9E9E),
            width: 24,
          ),
          activeItem: SvgPicture.asset(
            AppIcons.icCameraNavigation,
            color: Colors.red,
            width: 24,
          ),
          itemLabel: 'Camera',
        ),
        BottomBarItem(
          inActiveItem: SvgPicture.asset(
            AppIcons.icAiChat,
            color: const Color(0xFF9E9E9E),
            width: 24,
          ),
          activeItem: SvgPicture.asset(
            AppIcons.icAiChat,
            color: Colors.red,
            width: 24,
          ),
          itemLabel: 'AI Chat',
        ),
        BottomBarItem(
          inActiveItem: SvgPicture.asset(
            AppIcons.icSettings,
            color: const Color(0xFF9E9E9E),
            width: 24,
          ),
          activeItem: SvgPicture.asset(
            AppIcons.icSettings,
            color: Colors.red,
            width: 24,
          ),
          itemLabel: 'Setting',
        ),
      ],
    );
  }
}
