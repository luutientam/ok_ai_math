import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_math_2/presentation/ui/solve/page/solve_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../main.dart';
import '../../favorite/bloc/favorite_event.dart';
import '../bloc/solve_bloc.dart';
import '../bloc/solve_event.dart';
import '../bloc/solve_state.dart';

class SolveSuccessWidget extends StatefulWidget {
  final int id;

  const SolveSuccessWidget({super.key, required this.id});

  @override
  State<SolveSuccessWidget> createState() => _SolveSuccessWidgetState();
}

class _SolveSuccessWidgetState extends State<SolveSuccessWidget> {
  bool _isExpanded = false;
  final double headerHeight = 80;
  final double footerHeight = 110;

  @override
  void initState() {
    super.initState();
    // Gửi event load Math từ id
    context.read<SolveBloc>().add(LoadMathByIdEvent(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final double minPanelHeight = headerHeight + footerHeight;
    const borderColor = Color(0xFFDB1616);
    const textColor = Color(0xFFFDFDFD);
    const panelColor = Color(0xFF0A0D12);

    return BlocBuilder<SolveBloc, SolveState>(
      builder: (context, state) {
        if (state is SolveLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SolveErrorState) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is SolveSuccessState) {
          final math = state.math;


          return Stack(
            children: [
              if (_isExpanded)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              // GestureDetector "nửa màn hình dưới"
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: MediaQuery.of(context).size.height * 0.7, // nửa màn hình dưới
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy < -10) {
                      if (!_isExpanded) {
                        setState(() => _isExpanded = true);
                      }
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! < -300) {
                      setState(() => _isExpanded = true);
                    }
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
// GestureDetector "nửa màn hình trên" khi panel đang mở
              if (_isExpanded)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: MediaQuery.of(context).size.height * 0.7, // nửa trên
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 10) {
                        if (_isExpanded) {
                          setState(() => _isExpanded = false);
                        }
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! > 300) {
                        setState(() => _isExpanded = false);
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                top: _isExpanded ? 30 : null,
                bottom: 0,
                height: _isExpanded ? null : minPanelHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy < -10) {
                      if (!_isExpanded) {
                        setState(() => _isExpanded = true);
                      }
                    } else if (details.delta.dy > 10) {
                      if (_isExpanded) {
                        setState(() => _isExpanded = false);
                      }
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -300) {
                        setState(() => _isExpanded = true);
                      } else if (details.primaryVelocity! > 300) {
                        setState(() => _isExpanded = false);
                      }
                    }
                  },
                  child: Material(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                    color: panelColor,
                    child: Column(
                      children: [
                        // Header
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          child: Container(
                            height: headerHeight,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  _isExpanded
                                      ? 'assets/icons/ic_arrow_down.svg'
                                      : 'assets/icons/ic_arrow_up.svg',
                                  width: 43,
                                  height: 10,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Solve Math',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: const Color(0xFF414651),
                          width: double.infinity,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              if (_isExpanded)
                                SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 16,
                                    bottom: footerHeight + 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          color: panelColor,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                          child: Image.asset(
                                            'assets/images/img_premium_solve_math.webp',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Block 1: Kết quả
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: borderColor,
                                            width: 0.7,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          color: panelColor,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    final copyText = math.solution; // hoặc text tuỳ logic của Tâm
                                                    if (copyText.isNotEmpty) {
                                                      Clipboard.setData(ClipboardData(text: copyText));

                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible: false,
                                                        builder: (ctx) {
                                                          return Dialog(
                                                            backgroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: const [
                                                                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                                                                  SizedBox(width: 12),
                                                                  Text(
                                                                    "Copied to clipboard",
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      // Auto đóng sau 1s
                                                      Future.delayed(const Duration(seconds: 1), () {
                                                        if (Navigator.of(context).canPop()) {
                                                          Navigator.of(context).pop();
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: SvgPicture.asset(
                                                    'assets/icons/ic_copy.svg',
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (math.imageUri
                                                        .isNotEmpty) {
                                                      final bytes =
                                                      await File(math
                                                          .imageUri)
                                                          .readAsBytes();
                                                      Navigator
                                                          .pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              SolvePage(
                                                                imageBytes: bytes,
                                                                initialId:
                                                                math.uid,
                                                                isFromFavorite: math
                                                                    .isFavorite,
                                                                check: true,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: SvgPicture.asset(
                                                    'assets/icons/ic_repeat.svg',
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Solution',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              math.solution,
                                              style: const TextStyle(
                                                color: textColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                TextDecoration.none,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(
                                                color: Colors.white24),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Result',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              math.result,
                                              style: const TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                height: 1.5,
                                                decoration:
                                                TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              // Footer
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: footerHeight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: panelColor,
                                    borderRadius: _isExpanded
                                        ? null
                                        : const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: math.isFavorite
                                            ? SvgPicture.asset(
                                          'assets/icons/ic_favorite_selected.svg',
                                          width: 56,
                                          height: 56,
                                        )
                                            : SvgPicture.asset(
                                          'assets/icons/ic_favorite_select.svg',
                                          width: 56,
                                          height: 56,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<SolveBloc>()
                                              .add(ToggleFavoriteEvent(math));
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                              context, AppRoutes.camera);
                                        },
                                        child: Container(
                                          width: 275,
                                          height: 56,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: borderColor,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/ic_scan_math_solve.svg',
                                                width: 28,
                                                height: 28,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Scan Math',
                                                style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
