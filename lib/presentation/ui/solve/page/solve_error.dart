  import 'package:flutter/material.dart';
  import 'package:flutter_svg/flutter_svg.dart';

  class SolveErrorWidget extends StatelessWidget {
    const SolveErrorWidget({super.key});

    @override
    Widget build(BuildContext context) {
      return Positioned.fill(
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_hmm.svg',
                width: 135,
                height: 135,
              ),
              const SizedBox(height: 16),
              const Text(
                'Um… You take bad pictures!! There is no math involved. Want to try another picture?',
                style: TextStyle(color: Color(0xFFFDFDFD), fontSize: 16, decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  minimumSize: const Size(408, 56),
                ),
                child: SvgPicture.asset(
                  'assets/icons/ic_button_try_again.svg',
                  width: 408,
                  height: 56,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
