import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SingleShakeIcon extends StatefulWidget {
  final String iconAssetPath;
  final double size;
  final Duration duration;

  const SingleShakeIcon({
    super.key,
    required this.iconAssetPath,
    this.size = 48,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<SingleShakeIcon> createState() => _SingleShakeIconState();
}

class _SingleShakeIconState extends State<SingleShakeIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -0.4, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
      child: SvgPicture.asset(
        widget.iconAssetPath,
        width: widget.size,
        height: widget.size,
        // Không truyền color để giữ màu gốc SVG
      ),
    );
  }
}
