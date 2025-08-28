import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class HistoryEmptyWidget extends StatelessWidget {
  const HistoryEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center( // dùng Center để auto căn giữa cả theo trục X và Y
      child: Column(
        mainAxisSize: MainAxisSize.min, // chỉ chiếm đúng kích thước nội dung
        children: [
          SvgPicture.asset(
            'assets/icons/ic_hmm.svg',
            width: 135,
            height: 135,
          ),
          const SizedBox(height: 16),
          const Text(
            'No chat history !!',
            style: TextStyle(
              color: Color(0xFFFDFDFD),
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
