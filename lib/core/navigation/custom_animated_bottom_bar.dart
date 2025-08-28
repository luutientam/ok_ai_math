import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ai_math_2/app.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const CustomAnimatedBottomBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      itemCount: 4, // 4 item: Home, Camera, AI Chat, Setting
      tabBuilder: (int index, bool isActive) {
        // Xác định icon và label cho từng item
        final iconPath = [
          AppIcons.icHome,
          AppIcons.icCamera,
          AppIcons.icAiChat,
          AppIcons.icSettings,
        ][index];
        final label = [
          'Home',
          'Camera',
          'AI Chat',
          'Settings',
        ][index];
        final color = isActive ? AppColors.btnPrimary : const Color(0xFF717680);

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
      activeIndex: activeIndex,
      gapLocation: GapLocation.none, // Không có khoảng trống ở giữa
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 24,
      rightCornerRadius: 24,
      backgroundColor: AppColors.black,
      height: 80,
      splashSpeedInMilliseconds: 300,
      elevation: 8,
      shadow: BoxShadow(
        color: const Color(0xFFD9D9D9).withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      onTap: onTap,
    );
  }
}