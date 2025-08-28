import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_math_2/presentation/ui/history/page/take_photo_history_page.dart' hide showConfirmDialog;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/di.dart';
import '../bloc/ai_chat_history_bloc.dart';
import '../bloc/ai_chat_history_event.dart';
import '../bloc/ai_chat_history_state.dart';
import '../bloc/take_photo_history_bloc.dart';
import '../bloc/take_photo_history_event.dart';
import '../bloc/take_photo_history_state.dart';
import 'ai_chat_history_page.dart';

class HistoryTabsPage extends StatefulWidget {
  final bool initialTabIsPhoto;

  const HistoryTabsPage({Key? key, this.initialTabIsPhoto = true}) : super(key: key);

  @override
  State<HistoryTabsPage> createState() => _HistoryTabsPageState();
}

class _HistoryTabsPageState extends State<HistoryTabsPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIsPhoto ? 0 : 1;
  }

  void _switchTab(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
    _disableAllSelections();
    // Hủy selection mode cho cả 2 bloc luôn
    final takePhotoBloc = context.read<TakePhotoHistoryBloc>();
    final aiChatBloc = context.read<AiChatHistoryBloc>();

    if (takePhotoBloc.state is TakePhotoHistoryLoaded) {
      final state = takePhotoBloc.state as TakePhotoHistoryLoaded;
      if (state.isSelectionMode) {
        takePhotoBloc.add(const ToggleSelectionMode(enable: false));
      }
    }

    if (aiChatBloc.state is AiChatHistoryLoadedState) {
      final state = aiChatBloc.state as AiChatHistoryLoadedState;
      if (state.isSelectionMode) {
        aiChatBloc.add(AiChatHistoryDisableSelection());
      }
    }
  }
  void _disableAllSelections() {
    final takePhotoBloc = context.read<TakePhotoHistoryBloc>();
    final aiChatBloc = context.read<AiChatHistoryBloc>();

    if (takePhotoBloc.state is TakePhotoHistoryLoaded) {
      final state = takePhotoBloc.state as TakePhotoHistoryLoaded;
      if (state.isSelectionMode) takePhotoBloc.add(const ToggleSelectionMode(enable: false));
    }

    if (aiChatBloc.state is AiChatHistoryLoadedState) {
      final state = aiChatBloc.state as AiChatHistoryLoadedState;
      if (state.isSelectionMode) aiChatBloc.add(AiChatHistoryDisableSelection());
    }
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TakePhotoHistoryBloc>(
          create: (_) => sl<TakePhotoHistoryBloc>()..add(const LoadTakePhotoHistory()),
        ),
        BlocProvider<AiChatHistoryBloc>(
          create: (_) => sl<AiChatHistoryBloc>()..add(AiChatHistoryLoadAllSessionsEvent()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 70,
          centerTitle: true,
          leading: IconButton(
            icon: SvgPicture.asset('assets/icons/ic_back_formula.svg', width: 56, height: 56),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'History',
            style: TextStyle(
              color: Color(0xFFFDFDFD),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_currentIndex == 0)
              BlocBuilder<TakePhotoHistoryBloc, TakePhotoHistoryState>(
                builder: (context, state) {
                  if (state is! TakePhotoHistoryLoaded) return const SizedBox.shrink();
                  return _buildThreeDotsPhotos(context, state);
                },
              )
            else
              BlocBuilder<AiChatHistoryBloc, AiChatHistoryState>(
                builder: (context, state) {
                  if (state is! AiChatHistoryLoadedState) return const SizedBox.shrink();
                  return _buildThreeDotsAiChat(context, state);
                },
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF000000), // nền xung quanh tab bar
                  borderRadius: BorderRadius.circular(12), // bo tròn toàn bộ
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              "Take a photo",
                              style: TextStyle(
                                color: _currentIndex == 0 ? Colors.white : const Color(0xFFB0B0B0),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 2,
                              width: 60,
                              decoration: BoxDecoration(
                                color: _currentIndex == 0 ? Colors.red : Colors.transparent,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              "AI Math",
                              style: TextStyle(
                                color: _currentIndex == 1 ? Colors.white : const Color(0xFFB0B0B0),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 2,
                              width: 60,
                              decoration: BoxDecoration(
                                color: _currentIndex == 1 ? Colors.red : Colors.transparent,
                                borderRadius: BorderRadius.circular(1),
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
          ),




        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HistoryView(),
            AiChatHistoryPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeDotsPhotos(BuildContext context, TakePhotoHistoryLoaded state) {
    return Row(
      children: [
        state.isSelectionMode
            ? TextButton(
          onPressed: () => context.read<TakePhotoHistoryBloc>().add(ToggleSelectionMode(enable: false)),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Color(0xFFFDFDFD),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            : IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_ba_cham.svg',
            width: 56,
            height: 56,
          ),
          onPressed: () async {
            final choice = await showMenu<String>(
              context: context,
              position: const RelativeRect.fromLTRB(1000, 110, 16, 0),
              color: const Color(0xFF0A0D12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF717680), width: 1.5),
              ),
              items: [
                PopupMenuItem(value: 'select', child: _menuItemText('Select Item', Colors.white)),
                const PopupMenuDivider(height: 8),
                PopupMenuItem(value: 'delete', child: _menuItemText('Delete All', const Color(0xFFDB1616))),
              ],
            );

            if (choice == 'select') {
              context.read<TakePhotoHistoryBloc>().add(ToggleSelectionMode(enable: true));
            } else if (choice == 'delete') {
              if (state.takePhotoHistoryItems.isNotEmpty) {
                final confirmed = await showConfirmDialog(context, title: 'Delete all items?');
                if (confirmed) {
                  context.read<TakePhotoHistoryBloc>().add(const DeleteAllTakePhotoHistoryItems());
                }
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildThreeDotsAiChat(BuildContext context, AiChatHistoryLoadedState state) {
    return Row(
      children: [
        state.isSelectionMode
            ? TextButton(
          onPressed: () => context.read<AiChatHistoryBloc>().add(AiChatHistoryDisableSelection()),
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Color(0xFFFDFDFD),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            : IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_ba_cham.svg',
            width: 56,
            height: 56,
          ),
          onPressed: () async {
            final choice = await showMenu<String>(
              context: context,
              position: const RelativeRect.fromLTRB(1000, 110, 16, 0),
              color: const Color(0xFF0A0D12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF717680), width: 1.5),
              ),
              items: [
                PopupMenuItem(value: 'select', child: _menuItemText('Select Item', Colors.white)),
                const PopupMenuDivider(height: 8),
                PopupMenuItem(value: 'delete', child: _menuItemText('Delete All', const Color(0xFFDB1616))),
              ],
            );

            if (choice == 'select') {
              context.read<AiChatHistoryBloc>().add(AiChatHistoryEnableSelection());
            } else if (choice == 'delete') {
              if (state.sessions.isNotEmpty) {
                final confirmed = await showConfirmDialog(context, title: 'Delete all chats?');
                if (confirmed) {
                  context.read<AiChatHistoryBloc>().add(AiChatHistoryDeleteAll());
                }
              }
            }
          },
        ),
      ],
    );
  }

  Widget _menuItemText(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

/// --- Helper Confirm Dialog ---
Future<bool> showConfirmDialog(BuildContext context, {required String title}) async {
  return await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0A0D12),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFFFDFDFD), fontSize: 20),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFFDFDFD), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 80),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Color(0xFFDB1616), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  ) ??
      false;
}
