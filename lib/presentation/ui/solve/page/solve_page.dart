import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/di.dart';
import '../bloc/solve_bloc.dart';
import '../bloc/solve_event.dart';
import '../bloc/solve_state.dart';
import 'solve_loading.dart';
import 'solve_success.dart';
import 'solve_error.dart';

class SolvePage extends StatelessWidget {
  final Uint8List imageBytes;
  final int? initialId;
  final bool isFromFavorite;
  final bool check;

  const SolvePage({super.key, required this.imageBytes, this.initialId , this.isFromFavorite = false, this.check = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<SolveBloc>();
        if (initialId == null) {
          bloc.add(SolveSubmittedEvent(imageBytes));
        }else if (check) {
           bloc.add(SolveSubmittedEvent(imageBytes, updateDb: true, existingUid: initialId.toString(), isFavorite: isFromFavorite));
        }else {
          bloc.add(LoadMathByIdEvent(initialId!));
        }
        return bloc;
      },


      //SolveSubmittedEvent(imageBytes,updateDb: true, existingUid: initialId.toString() , isFavorite: isFromFavorite)
      child: BlocBuilder<SolveBloc, SolveState>(
        builder: (context, state) {
          final loading = state is SolveLoadingState;
          final success = state is SolveSuccessState ? state : null;
          final hasError = state is SolveErrorState;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
                    iconSize: 64,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: SvgPicture.asset(
                        'assets/icons/ic_back_formula.svg',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.memory(imageBytes, fit: BoxFit.contain),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (success != null)
                  SolveSuccessWidget(id: success.math.uid!),
              if (loading) const SolveLoadingWidget(),
              if (hasError) const SolveErrorWidget(),
            ],
          );
        },
      ),
    );
  }
}