import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ai_math_2/app.dart';

import 'formula_detail_screen.dart';

import '../../../widgets/custom_success_dialog.dart';

class FormulaPage extends StatefulWidget {
  const FormulaPage({super.key});

  @override
  State<FormulaPage> createState() => _FormulaPageState();
}

class _FormulaPageState extends State<FormulaPage> {
  bool showSaved = false;
  Map<int, bool> expanded = {};
  // Cache last known saved flags to detect changes
  Map<int, bool> _lastSaved = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181D27),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          backgroundColor: const Color(0xFF0A0D12),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_back_formula.svg',
              width: 58,
              height: 58,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Formula', style: TextStyle(color: Colors.white)),
        ),
      ),

      body: BlocListener<FormulaItemBloc, FormulaItemState>(
        listenWhen: (previous, current) =>
            current is FormulaItemAllState || current is FormulaItemErrorState,
        listener: (context, state) {
          if (state is FormulaItemErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          if (state is FormulaItemAllState) {
            // Build current map of uid -> isSaved
            final currentMap = <int, bool>{};
            for (final it in state.allItems) {
              if (it.uid != null) currentMap[it.uid!] = it.isSaved;
            }

            // Find the first changed item compared to previous snapshot
            int? changedId;
            bool? newSaved;
            for (final entry in currentMap.entries) {
              final prev = _lastSaved[entry.key];
              if (prev != null && prev != entry.value) {
                changedId = entry.key;
                newSaved = entry.value;
                break;
              }
            }

            if (changedId != null && newSaved != null) {
              if (newSaved) {
                showSuccessDialog(
                  context,
                  'You have saved the formula successfully.',
                );
              }
            }

            // Update snapshot
            _lastSaved = currentMap;
          }
        },
        child: Column(
          children: [
            _buildTabs(),
            Expanded(
              child: BlocBuilder<FormulaBloc, FormulaState>(
                builder: (context, state) {
                  // Debug logging
                  print(
                    '[FormulaPage] FormulaBloc state: ${state.runtimeType}',
                  );

                  // Loading and error handling
                  if (state is FormulaLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    );
                  }
                  if (state is FormulaErrorState) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  // We only render list when we have all formulas
                  if (state is! FormulaWatchAllState) {
                    return const SizedBox.shrink();
                  }

                  final formulas = state.formulas;
                  print('[FormulaPage] Formulas count: ${formulas.length}');

                  // Empty state for All tab when no formulas are available
                  if (!showSaved && (formulas.isEmpty)) {
                    return const Center(
                      child: Text(
                        'No formulas',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  if (showSaved) {
                    return BlocBuilder<FormulaItemBloc, FormulaItemState>(
                      builder: (context, itemState) {
                        if (itemState is FormulaItemLoadingState) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.yellow,
                            ),
                          );
                        }
                        if (itemState is FormulaItemErrorState) {
                          return Center(
                            child: Text(
                              itemState.message,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }
                        if (itemState is! FormulaItemAllState) {
                          return const SizedBox.shrink();
                        }

                        final savedItems = itemState.allItems
                            .where((e) => e.isSaved)
                            .toList();
                        if (savedItems.isEmpty) {
                          return const Center(
                            child: Text(
                              "No saved formulas",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: savedItems.length,
                          itemBuilder: (context, index) {
                            final item = savedItems[index];
                            // Find parent formula for this saved item
                            Formula? parentFormula;
                            try {
                              parentFormula = formulas.firstWhere(
                                (f) => f.uid == item.formulaId,
                              );
                            } catch (_) {
                              parentFormula = null;
                            }
                            return GestureDetector(
                              onTap: () {
                                final f = parentFormula;
                                if (f == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<FormulaItemBloc>(),
                                      child: FormulaDetailPage(
                                        formula: f,
                                        item: item,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: _buildSavedItemTile(item),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    // Show formulas list; items resolved via FormulaItemBloc by filtering per formulaId
                    return BlocBuilder<FormulaItemBloc, FormulaItemState>(
                      builder: (context, itemState) {
                        // Debug logging
                        print(
                          '[FormulaPage] FormulaItemBloc state: ${itemState.runtimeType}',
                        );

                        final allItems = itemState is FormulaItemAllState
                            ? itemState.allItems
                            : <FormulaItem>[];
                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: formulas.length,
                          itemBuilder: (context, index) {
                            final formula = formulas[index];
                            final isExpanded = expanded[formula.uid] ?? false;
                            final itemsForFormula = allItems
                                .where(
                                  (it) => it.formulaId == (formula.uid ?? -1),
                                )
                                .toList();
                            return Column(
                              children: [
                                _buildFormulaHeader(
                                  formula,
                                  isExpanded,
                                  itemsForFormula.length,
                                ),
                                if (isExpanded)
                                  _buildFormulaItems(formula, itemsForFormula),
                                const SizedBox(height: 17),
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const selectedColor = Color(0xFFEDEF5D);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => showSaved = false);
                },
                child: Container(
                  margin: const EdgeInsets.all(4), // cách viền trong 8px
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: !showSaved ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "All",
                    style: TextStyle(
                      color: !showSaved ? Colors.black : selectedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => showSaved = true);
                },
                child: Container(
                  margin: const EdgeInsets.all(4), // cách viền trong 8px
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: showSaved ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Saved",
                    style: TextStyle(
                      color: showSaved ? Colors.black : selectedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaHeader(Formula formula, bool isExpanded, int count) {
    return GestureDetector(
      onTap: () => setState(() {
        expanded[formula.uid!] = !isExpanded;
      }),
      child: SizedBox(
        height: 80,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(formula.iconPath, width: 56, height: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formula.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$count', // hiển thị số lượng thực tế
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Formula",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: SvgPicture.asset(
                  'assets/icons/ic_expand_more.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulaItems(Formula formula, List<FormulaItem> items) {
    return Container(
      margin: const EdgeInsets.only(top: 16), // cách item cha 16dp
      child: Column(
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FormulaItemBloc>(),
                    child: FormulaDetailPage(formula: formula, item: item),
                  ),
                ),
              );
            },
            child: SizedBox(
              height: 60,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Color(
                            0xFFFDFDFD,
                          ), // 0xFF là alpha (độ trong suốt 100%)
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        item.isSaved
                            ? 'assets/icons/ic_bookmark_filled.svg'
                            : 'assets/icons/ic_bookmark_outline.svg',
                        width: 30,
                        height: 30,
                      ),
                      onPressed: () {
                        context.read<FormulaItemBloc>().add(
                          FormulaItemToggleSaveEvent(item),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSavedItemTile(FormulaItem item) {
    return SizedBox(
      height: 60,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(color: Color(0xFFFDFDFD), fontSize: 14),
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                item.isSaved
                    ? 'assets/icons/ic_bookmark_filled.svg'
                    : 'assets/icons/ic_bookmark_outline.svg',
                width: 30,
                height: 30,
              ),
              onPressed: () {
                context.read<FormulaItemBloc>().add(
                  FormulaItemToggleSaveEvent(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
