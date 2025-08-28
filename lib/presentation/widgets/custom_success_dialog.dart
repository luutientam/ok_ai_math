import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> showSuccessDialog(BuildContext context, String message) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return Opacity(
        opacity: animation1.value,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD5D7DA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SvgPicture.asset(
                  'assets/icons/ic_save_succes.svg',
                  width: 36,
                  height: 36,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // Tự đóng sau 1.2s
  await Future.delayed(const Duration(milliseconds: 1200));
  if (context.mounted) Navigator.pop(context);
}
