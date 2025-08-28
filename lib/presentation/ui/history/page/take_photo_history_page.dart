import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/models/math.dart';
import '../../solve/page/solve_error.dart';
import '../../solve/page/solve_page.dart';

import '../bloc/ai_chat_history_bloc.dart';
import '../bloc/ai_chat_history_event.dart';
import '../bloc/take_photo_history_bloc.dart';
import '../bloc/take_photo_history_event.dart';
import '../bloc/take_photo_history_state.dart';
import 'ai_chat_history_page.dart';
import 'history_empty.dart';

/// --- Extension: Group Math items by Date ---
extension MathGrouping on List<Math> {
  Map<String, List<Math>> groupByDate() {
    final Map<String, List<Math>> grouped = {};
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final item in this) {
      if (item.createdAt == null) continue;
      final date = DateTime(
        item.createdAt!.year,
        item.createdAt!.month,
        item.createdAt!.day,
      );

      final key = date == todayDate
          ? 'Today'
          : '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}';

      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
}

/// --- Helper: Show Confirm Dialog ---
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
          fontSize: 20
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 2 nút 2 bên
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
  ) ?? false;
}
Future<String?> showSelectDeleteDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    barrierColor: Colors.black54, // nền mờ phía sau
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0D12), // nền tối
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDB1616), width: 2), // viền đỏ ngoài
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // nút Select Item
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, 'select'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF0A0D12),
                ),
                child: const Text(
                  'Select Item',
                  style: TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // nút Delete All
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF0A0D12),
                  side: const BorderSide(color: Color(0xFFDB1616), width: 2), // viền đỏ riêng nút
                ),
                child: const Text(
                  'Delete All',
                  style: TextStyle(
                    color: Color(0xFFDB1616),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



/// --- HistoryPage Entry ---
class TakePhotoHistoryPage extends StatelessWidget {
  const TakePhotoHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HistoryView();
  }
}

/// --- HistoryView ---
class HistoryView extends StatelessWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF000000),
      body: BlocBuilder<TakePhotoHistoryBloc, TakePhotoHistoryState>(
        builder: (context, state) {
          if (state is TakePhotoHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TakePhotoHistoryError) {
            return Center(child: Text(state.message));
          } else if (state is TakePhotoHistoryLoaded) {
            if (state.takePhotoHistoryItems.isEmpty) {
              return const HistoryEmptyWidget();
            }

            final groupedItems = state.takePhotoHistoryItems.groupByDate();

            return ListView(
              children: groupedItems.entries.map((entry) {
                final date = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ở trong ListView builder
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (state.isSelectionMode)
                            GestureDetector(
                              onTap: () {
                                final allSelectedInGroup = items.every(
                                      (item) => state.selectedItems[item.uid] ?? false,
                                );

                                context.read<TakePhotoHistoryBloc>().add(
                                  ToggleSelectByDate(
                                    items.first.createdAt!,
                                    !allSelectedInGroup,
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                items.every((item) => state.selectedItems[item.uid] ?? false)
                                    ? 'assets/icons/ic_checkbox_checked.svg'   // checked
                                    : 'assets/icons/ic_checkbox_unchecked.svg', // unchecked
                                width: 24,
                                height: 24, // nếu muốn màu trắng
                              ),

                            ),
                          if (state.isSelectionMode)
                            const SizedBox(width: 8), // khoảng cách giữa checkbox và text
                          Text(
                            date,
                            style: const TextStyle(fontSize: 16, color: Color(0xFFFDFDFD)),
                          ),
                        ],
                      ),
                    ),


                    ...items.map((item) {
                      final isSelected = state.selectedItems[item.uid] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: _HistoryItem(
                          math: item,
                          isSelected: isSelected,
                          isSelectionMode: state.isSelectionMode,
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),

      /// BOTTOM BAR
      bottomNavigationBar: BlocBuilder<TakePhotoHistoryBloc, TakePhotoHistoryState>(
        builder: (context, state) {
          if (state is TakePhotoHistoryLoaded && state.isSelectionMode) {
            final selectedCount = state.selectedItems.values.where((e) => e).length;
            final allSelected = selectedCount == state.takePhotoHistoryItems.length;

            return Container(
              height: 100,
              color: const Color(0xFF0A0D12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bên trái: icon + Select All
                  TextButton.icon(
                    onPressed: state.takePhotoHistoryItems.isNotEmpty
                        ? () {
                      context.read<TakePhotoHistoryBloc>().add(
                        SelectAllTakePhotoHistoryItems(!allSelected),
                      );
                    }
                        : null, // disable nếu không có item
                    icon: SvgPicture.asset(
                      (selectedCount > 0 && allSelected)
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



                  // Bên phải: số lượng + Delete
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
                  )



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
      BuildContext context, TakePhotoHistoryLoaded state) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Are you sure you want to delete all search history?',
    );
    if (confirmed) {
      context
          .read<TakePhotoHistoryBloc>()
          .add(DeleteSelectedTakePhotoHistoryItems(state.selectedItems.keys.toList()));
    }
  }
}

/// --- Single History Item ---
class _HistoryItem extends StatelessWidget {
  final Math math;
  final bool isSelected;
  final bool isSelectionMode;

  const _HistoryItem({
    Key? key,
    required this.math,
    required this.isSelected,
    required this.isSelectionMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onTap(context),
      child: Stack(
        children: [
          // Checkbox bên trái với khoảng cách 16
          if (isSelectionMode)
            Positioned(
              left: 8, // cách mép trái 16
              top: 0,
              bottom: 0,
              width: 40,
              child: GestureDetector(
                onTap: () {
                  final currentState = context.read<TakePhotoHistoryBloc>().state;
                  if (currentState is TakePhotoHistoryLoaded) {
                    context.read<TakePhotoHistoryBloc>().add(
                      ToggleTakePhotoHistorySelection(
                        math,
                        !(currentState.selectedItems[math.uid] ?? false),
                      ),
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    isSelected
                        ? 'assets/icons/ic_checkbox_checked.svg'   // icon checked
                        : 'assets/icons/ic_checkbox_unchecked.svg', // icon unchecked
                    width: 24,
                    height: 24, // nếu muốn màu trắng
                  ),
                ),
              ),
            ),

          // Item trượt sang phải khi selection mode
          AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: isSelectionMode ? const Offset(0.12, 0) : Offset.zero,
            curve: Curves.easeInOut,
            child: Container(
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // vẫn giữ margin 16
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[800] : const Color(0xFF0A0D12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: math.imageUri != null && math.imageUri!.isNotEmpty
                    ? Image.file(
                  File(math.imageUri!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
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

  void _onTap(BuildContext context) async {
    if (isSelectionMode) {
      final currentState = context.read<TakePhotoHistoryBloc>().state;
      if (currentState is TakePhotoHistoryLoaded) {
        context.read<TakePhotoHistoryBloc>().add(
          ToggleTakePhotoHistorySelection(
            math,
            !(currentState.selectedItems[math.uid] ?? false),
          ),
        );
      }
    } else {
      if (math.imageUri != null && math.imageUri!.isNotEmpty) {
        final bytes = await File(math.imageUri!).readAsBytes();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SolvePage(
              imageBytes: bytes,
              initialId: math.uid,
              isFromFavorite: math.isFavorite,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image available for this math item')),
        );
      }
    }
  }
}



