import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BtnLifetimeWidget extends StatelessWidget {
  final String price;
  final VoidCallback onPressed;

  const BtnLifetimeWidget({
    super.key,
    required this.price,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xFF5100FD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Lifetime',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // SvgPicture.asset(
                  //   'assets/icons/ic_sub_star.svg',
                  //   width: 24,
                  //   height: 24,
                  // ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'One-time purchase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
