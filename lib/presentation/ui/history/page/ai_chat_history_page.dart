import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/models/math_ai_session_with_first_message.dart';
import '../../math_ai_chat/bloc/math_ai_chat_bloc.dart';
import '../../math_ai_chat/pages/math_ai_chat_detail_page.dart';
import '../../math_ai_chat/pages/math_ai_chat_page.dart';
import '../bloc/ai_chat_history_bloc.dart';
import '../bloc/ai_chat_history_event.dart';
import '../bloc/ai_chat_history_state.dart';
import 'history_empty.dart';

/// --- Extension: Group AiChat sessions by Date ---
extension SessionGrouping on List<MathAiSessionWithFirstMessage> {
  Map<String, List<MathAiSessionWithFirstMessage>> groupByDate() {
    final Map<String, List<MathAiSessionWithFirstMessage>> grouped = {};
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final session in this) {
      final createdAt = DateTime.parse(session.mathAi.createdAt);
      final date = DateTime(createdAt.year, createdAt.month, createdAt.day);

      final key = date == todayDate
          ? 'Today'
          : '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}';

      grouped.putIfAbsent(key, () => []).add(session);
    }
    return grouped;
  }
}

/// --- AiChatHistoryPage ---
class AiChatHistoryPage extends StatelessWidget {
  const AiChatHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _HistoryView();
  }
}

/// --- HistoryView ---
class _HistoryView extends StatelessWidget {
  const _HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: BlocBuilder<AiChatHistoryBloc, AiChatHistoryState>(
        builder: (context, state) {
          if (state is AiChatHistoryLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AiChatHistoryErrorState) {
            return Center(child: Text(state.message));
          } else if (state is AiChatHistoryLoadedState) {
            if (state.sessions.isEmpty) return const HistoryEmptyWidget();

            final groupedItems = state.sessions.groupByDate();

            return ListView(
              children: groupedItems.entries.map((entry) {
                final date = entry.key;
                final items = entry.value;

                final allSelectedInDate = items.every(
                      (s) => state.selectedItems[s.mathAi.uid] == true,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Date header with select-all-per-day ---
                    // --- inside ListView builder ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (state.isSelectionMode)
                            GestureDetector(
                              onTap: () {
                                for (var s in items) {
                                  if (s.mathAi.uid != null) {
                                    context.read<AiChatHistoryBloc>().add(
                                      AiChatHistoryToggleSelection(
                                        s.mathAi.uid!,
                                        !allSelectedInDate,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: SvgPicture.asset(
                                allSelectedInDate
                                    ? 'assets/icons/ic_checkbox_checked.svg'
                                    : 'assets/icons/ic_checkbox_unchecked.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: const TextStyle(fontSize: 16, color: Color(0xFFFDFDFD)),
                          ),
                        ],
                      ),
                    ),

                    // --- List of sessions under this date ---
                    ...items.map((session) {
                      final isSelected = state.selectedItems[session.mathAi.uid] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: _HistoryItem(
                          session: session,
                          isSelected: isSelected,
                          isSelectionMode: state.isSelectionMode,
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
      bottomNavigationBar: BlocBuilder<AiChatHistoryBloc, AiChatHistoryState>(
        builder: (context, state) {
          if (state is AiChatHistoryLoadedState && state.isSelectionMode) {
            final selectedCount = state.selectedItems.values.where((e) => e).length;
            final allSelected = selectedCount > 0 && selectedCount == state.sessions.length;

            return Container(
              height: 100,
              color: const Color(0xFF0A0D12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Select All button ---
                  TextButton.icon(
                    onPressed: selectedCount >= 0
                        ? () {
                      context.read<AiChatHistoryBloc>().add(
                        AiChatHistorySelectAll(!allSelected),
                      );
                    }
                        : null, // disabled nếu không có item chọn
                    icon: SvgPicture.asset(
                      allSelected
                          ? 'assets/icons/ic_checkbox_checked.svg'
                          : 'assets/icons/ic_checkbox_unchecked.svg',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      "Select All",
                      style: TextStyle(color: Color(0xFFFDFDFD)),
                    ),
                  ),

                  // --- Delete button + count ---
                  Container(
                    height: 50,
                    width: 240,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB1616),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: selectedCount > 0
                              ? () => _deleteSelected(context, state)
                              : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "( $selectedCount )",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),

    );
  }

  Future<void> _deleteSelected(
      BuildContext context, AiChatHistoryLoadedState state) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Are you sure you want to delete selected chats?',
    );
    if (confirmed) {
      context.read<AiChatHistoryBloc>().add(
        AiChatHistoryDeleteSelected(
          state.selectedItems.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList(),
        ),
      );
    }
  }
}

/// --- Single History Item ---
class _HistoryItem extends StatelessWidget {
  final MathAiSessionWithFirstMessage session;
  final bool isSelected;
  final bool isSelectionMode;

  const _HistoryItem({
    Key? key,
    required this.session,
    required this.isSelected,
    required this.isSelectionMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstMessage = session.firstMessage;

    return InkWell(
      onTap: () => _onTap(context),
      child: Stack(
        children: [
          if (isSelectionMode)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              width: 40,
              child: GestureDetector(
                onTap: () {
                  final currentState = context.read<AiChatHistoryBloc>().state;
                  if (currentState is AiChatHistoryLoadedState) {
                    context.read<AiChatHistoryBloc>().add(
                      AiChatHistoryToggleSelection(
                        session.mathAi.uid!,
                        !(currentState.selectedItems[session.mathAi.uid!] ?? false),
                      ),
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    isSelected
                        ? 'assets/icons/ic_checkbox_checked.svg'
                        : 'assets/icons/ic_checkbox_unchecked.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: isSelectionMode ? const Offset(0.12, 0) : Offset.zero,
            curve: Curves.easeInOut,
            child: Container(
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0A0D12) : const Color(0xFF0A0D12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: firstMessage != null
                    ? (firstMessage.imagePath != null
                    ? Image.file(
                  File(firstMessage.imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
                    : (firstMessage.content != null
                    ? Container(
                  color: const Color(0xFF1E1E1E),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    firstMessage.content!,
                    style: const TextStyle(
                      color: Color(0xFFFDFDFD),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : const ColoredBox(
                  color: Colors.black12,
                  child: Center(
                    child: Text(
                      'No Image',
                      style: TextStyle(color: Color(0xFFFDFDFD)),
                    ),
                  ),
                )))
                    : const ColoredBox(
                  color: Colors.black12,
                  child: Center(
                    child: Text(
                      'No Image',
                      style: TextStyle(color: Color(0xFFFDFDFD)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (isSelectionMode) {
      final currentState = context.read<AiChatHistoryBloc>().state;
      if (currentState is AiChatHistoryLoadedState) {
        context.read<AiChatHistoryBloc>().add(
          AiChatHistoryToggleSelection(
            session.mathAi.uid!,
            !(currentState.selectedItems[session.mathAi.uid!] ?? false),
          ),
        );
      }
    } else {
      final uid = session.mathAi.uid;
      if (uid != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<MathAiChatBloc>(),
              child: MathAiChatDetailPage(mathAiId: uid),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image or invalid session ID')),
        );
      }
    }
  }

}


/// --- Helper Confirm Dialog ---
Future<bool> showConfirmDialog(
    BuildContext context, {
      required String title,
    }) async {
  return await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0A0D12),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFDFDFD),
          fontSize: 20,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFFFDFDFD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 80),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Color(0xFFDB1616),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ) ??
      false;
}
