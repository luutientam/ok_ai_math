import 'package:flutter/material.dart';
import '../../../widgets/loading_shake.dart';

class SolveLoadingWidget extends StatelessWidget {
  const SolveLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 250.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SingleShakeIcon(
                iconAssetPath: 'assets/icons/ic_loading_1.svg',
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Solving math problem. Please wait.',
                style: TextStyle(color: Color(0xFFFDFDFD), fontSize: 18,decoration: TextDecoration.none),
                textAlign: TextAlign.center,

              ),
            ],
          ),
        ),
      ),
    );
  }
}
