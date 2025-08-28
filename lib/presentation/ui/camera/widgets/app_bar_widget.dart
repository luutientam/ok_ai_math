import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/icons.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final paddingBarTop = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.black.withOpacity(0.5),  // sửa fromValues thành withOpacity
      padding: EdgeInsets.only(
        top: paddingBarTop + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  context.read<CameraBloc>().add(CameraStoppedEvent());
                  Navigator.pop(context);
                },
                icon: SvgPicture.asset(
                  AppIcons.icBack,
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              _buildBtnTip(context),
            ],
          ),


          Positioned.fill(
            child: _buildTitle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return const Center(
      child: Text(
        'Camera',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBtnTip(BuildContext context) {
    return InkWell(
      onTap: () => _showScanTipsBottomSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2), // sửa fromValues thành withOpacity
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppIcons.icTip, width: 16, height: 16),
            const SizedBox(width: 8),
            const Text(
              'Tips',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanTipsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0D12),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/ic_close_tip.svg',
                      width: 32,
                      height: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: const Text(
                        'Scan Tips',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Khoảng trống cân bằng nút close
                ],
              ),

              const Divider(color: Colors.white24),
              // Danh sách tips
              Expanded(
                child: ListView(
                  children: const [
                    _TipItem(
                      number: 1,
                      text: 'Only one complete question per image',
                      assetImage: 'assets/images/tips_1.webp',
                      textColor: Colors.white,
                    ),
                    _TipItem(
                      number: 2,
                      text: 'Keep the image clear and focused',
                      assetImage: 'assets/images/tips_2.webp',
                      textColor: Colors.white,
                    ),
                    _TipItem(
                      number: 3,
                      text: 'The photo is too dark to see anything? Turn on the flash!',
                      assetImage: 'assets/images/tips_3.webp',
                      textColor: Colors.white,
                    ),
                    _TipItem(
                      number: 4,
                      text: 'Printed text is easier to read. Your handwriting is so bad!!',
                      assetImage: 'assets/images/tips_4.webp',
                      textColor: Colors.white,
                    ),
                    _TipItem(
                      number: 5,
                      text: 'Keep the machine steady and straight. Your hand is shaking too much.',
                      assetImage: 'assets/images/tips_5.webp',
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TipItem extends StatelessWidget {
  const _TipItem({
    super.key,
    required this.number,
    required this.text,
    required this.assetImage,
    required this.textColor,
  });

  final int number;
  final String text;
  final String assetImage;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // căn giữa ngang
        children: [
          Text(
            '$number. $text',
            textAlign: TextAlign.center, // căn giữa text
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(assetImage),
        ],
      ),
    );
  }
}

