import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/models/formula.dart';
import '../../../../domain/models/formula_item.dart';
import '../bloc/formula_item_bloc.dart';
import '../bloc/formula_item_event.dart';
import '../bloc/formula_item_state.dart';

class FormulaDetailPage extends StatefulWidget {
  final Formula formula;
  final FormulaItem item;

  const FormulaDetailPage({
    super.key,
    required this.formula,
    required this.item,
  });

  @override
  State<FormulaDetailPage> createState() => _FormulaDetailPageState();
}

class _FormulaDetailPageState extends State<FormulaDetailPage> {
  late bool isSavedLocal;

  @override
  void initState() {
    super.initState();
    isSavedLocal = widget.item.isSaved;
  }

  void _toggleSave() {
    final toggledValue = !isSavedLocal;
    setState(() {
      isSavedLocal = toggledValue;
    });

    final toggledItem = widget.item.copyWith(isSaved: toggledValue);
    context.read<FormulaItemBloc>().add(FormulaItemToggleSaveEvent(toggledItem));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61), // tăng thêm 1 height cho line
        child: AppBar(
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_back_formula_detail.svg',
              width: 56,
              height: 56,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.formula.name,
            style: const TextStyle(
              color: Color(0xFFFDFDFD),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0E0E0E),

          // <-- Thêm dòng này:
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.grey.shade700, // màu đường line
            ),
          ),

          actions: [
            BlocBuilder<FormulaItemBloc, FormulaItemState>(
              builder: (context, state) {
                bool currentSaved = isSavedLocal;

                if (state is FormulaItemAllState) {
                  final found = state.allItems.firstWhere(
                        (i) => i.uid == widget.item.uid,
                    orElse: () => widget.item,
                  );
                  currentSaved = found.isSaved;
                } else if (state is FormulaItemListState) {
                  final found = state.items.firstWhere(
                        (i) => i.uid == widget.item.uid,
                    orElse: () => widget.item,
                  );
                  currentSaved = found.isSaved;
                }

                return IconButton(
                  icon: SvgPicture.asset(
                    currentSaved
                        ? 'assets/icons/ic_bookmark_filled_detail.svg'
                        : 'assets/icons/ic_bookmark_outline_detail.svg',
                    width: 56,
                    height: 56,
                  ),
                  onPressed: _toggleSave,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),



      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView(
          children: [
            // Ảnh full width (bỏ padding cho ảnh)
            ClipRRect(
              child: Image.asset(
                widget.item.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,  // đảm bảo ảnh rộng full vùng chứa
              ),
            ),
          ],
        ),
      ),


    );
  }
}
