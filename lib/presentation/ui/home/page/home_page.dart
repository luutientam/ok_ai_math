import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/di/di.dart';import '../../../../core/routes/app_routes.dart';



import '../../../../domain/usecases/math_ai_chat_use_case.dart';
import '../../../../domain/usecases/math_ai_use_case.dart';
import '../../math_ai_chat/bloc/math_ai_chat_bloc.dart';
import '../../math_ai_chat/pages/math_ai_chat_page.dart';

class HomePage extends StatelessWidget {
  final Function(int) onItemTapped;

  const HomePage({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    const circleAvatarColor = Color(0xFF48484A);
    final MathAiUseCase mathAiUseCase = sl<MathAiUseCase>();
    final MathAiChatUseCase mathAiChatUseCase = sl<MathAiChatUseCase>();
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background_home.webp', // đổi sang ảnh bạn muốn
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ===== Custom AppBar cách top 16px =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.history);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/icons/ic_history.svg',
                              width: 56,
                              height: 56,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ===== Body Scroll =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scan Math Card
                        Container(
                          padding: const EdgeInsets.all(1),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {},
                              child: Image.asset(
                                'assets/images/img_upgrade_pre.webp',
                                width: double.infinity,
                                height: 140,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Math tools section
                        Center(
                          child: const Text(
                            'Solve math easily with image recognition and Ai Math',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontStyle: FontStyle.italic, // chữ nghiêng
                            ),
                          ),
                        ),


                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: const Color(0xFF5B0093), // Card 1 màu tím
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFF48484A), width: 1.5),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    onItemTapped(1);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.black26,
                                          child: Image.asset(
                                            'assets/images/img_photo.webp',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),

                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Identify by photo',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,

                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16), // khoảng cách giữa 2 Card
                            Expanded(
                              child: Card(
                                color: const Color(0xFF02359C), // Card 2 màu xanh
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFF48484A), width: 1.5),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Use the callback to change tabs
                                    onItemTapped(2); // AI Chat tab index
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.black26,
                                          child: Image.asset(
                                            'assets/images/img_chat.webp',
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                          ),

                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Chat AI Math',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                 
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
