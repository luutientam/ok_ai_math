import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:flutter_ai_math_2/presentation/ui/solve/bloc/solve_event.dart';
import 'package:flutter_ai_math_2/presentation/ui/solve/bloc/solve_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../domain/models/math.dart';
import '../../../../domain/usecases/gemini_use_case.dart';
import '../../../../domain/usecases/math_use_case.dart';

class SolveBloc extends Bloc<SolveEvent, SolveState> {
  final GeminiUseCase geminiUseCase;
  final MathUseCase mathUseCase;

  SolveBloc({required this.geminiUseCase, required this.mathUseCase})
      : super(const SolveInitialState()) {
    on<SolveSubmittedEvent>(_onSolveSubmitted);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SolveResetEvent>((event, emit) => emit(const SolveInitialState()));
    on<LoadMathByIdEvent>(_onLoadMathById);
  }
  Future<void> _onLoadMathById(
      LoadMathByIdEvent event, Emitter<SolveState> emit) async {
    emit(const SolveLoadingState());
    try {
      final math = await mathUseCase.selectById(event.id);
      if (math != null) {
        emit(SolveSuccessState(math));
      } else {
        emit(const SolveErrorState('Math not found'));
      }
    } catch (e) {
      emit(SolveErrorState(e.toString()));
    }
  }
  @override
  void onEvent(SolveEvent event) {
    developer.log('Event: $event', name: 'SolveBloc');
    super.onEvent(event);
  }

  @override
  void onChange(Change<SolveState> change) {
    developer.log(
      'State: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      name: 'SolveBloc',
    );
    super.onChange(change);
  }

  Future<void> _onSolveSubmitted(
      SolveSubmittedEvent event,
      Emitter<SolveState> emit,
      ) async {
    developer.log(
      'SolveSubmittedEvent received: updateDb=${event.updateDb}, existingUid=${event.existingUid}',
      name: 'SolveBloc',
    );

    emit(const SolveLoadingState());

    try {
      //  Lưu ảnh cục bộ
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'capture_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(event.imageBytes);
      developer.log('Image saved to: ${file.path}', name: 'SolveBloc');

      // 2️⃣ Phân tích ảnh
      final analyzed = await geminiUseCase.analyzeImageToMath(file);
      print('Analyzed data from geminiUseCase: ${analyzed?.toMap()}');
      if (analyzed == null) {
        const error = 'Unable to analyze the image';
        developer.log(error, name: 'SolveBloc');
        emit(SolveErrorState(error));
        return;
      }
      print('Analyzed result: ${analyzed.toMap()}');

      // 3Tạo đối tượng Math
      print('Creating Math object with:');
      print('- result: ${analyzed.result}');
      print('- solution: ${analyzed.solution}');
      final math = Math(
        uid: (event.existingUid != null) ? int.tryParse(event.existingUid!) : null,
        result: analyzed.result,
        imageUri: analyzed.imageUri.isNotEmpty ? analyzed.imageUri : file.path,
        solution: analyzed.solution,
        isFavorite: event.isFavorite,
        createdAt: DateTime.now(),

      );
      print('Math object created: ${math.toMap()}');
      developer.log('Math object created: ${math.toMap()}', name: 'SolveBloc');

      Math mathForState = math;

      // 4️⃣ Lưu/update DB nếu cần
      if (event.updateDb) {
        if (event.existingUid != null) {
          // Update existing record
          try {
            final existingId = int.tryParse(event.existingUid!);
            if (existingId != null) {
              final existingMath = await mathUseCase.selectById(existingId);
              if (existingMath != null) {
                developer.log('Before update: ${existingMath.toMap()}', name: 'SolveBloc');
                await mathUseCase.update(math);
                developer.log('After update: ${math.toMap()}', name: 'SolveBloc');
              } else {
                developer.log('Record with uid=${event.existingUid} not found, skipping update', name: 'SolveBloc');
              }
            } else {
              developer.log('Invalid existingUid format: ${event.existingUid}', name: 'SolveBloc');
            }
          } catch (e) {
            developer.log('Error updating math: $e', name: 'SolveBloc', error: e);
          }
        } else {
          // Insert mới
          try {
            developer.log('Inserting new Math: ${math.toMap()}', name: 'SolveBloc'); // 🔹 log dữ liệu trước insert
            final insertedId = await mathUseCase.insert(math);
            developer.log('Inserted new Math with uid=$insertedId', name: 'SolveBloc');

            // Tạo Math mới để emit, tránh gán lại uid nếu là late final
            mathForState = Math(
              uid: insertedId,
              result: math.result,
              imageUri: math.imageUri,
              solution: math.solution,
              isFavorite: false,
              createdAt: math.createdAt,
            );
            developer.log('Math object after insert: ${mathForState.toMap()}', name: 'SolveBloc'); // axdrde log dữ liệu sau insert
          } catch (e) {
            developer.log('Error inserting math: $e', name: 'SolveBloc', error: e);
          }
        }
      } else {
        developer.log('updateDb=false, skipping DB operation', name: 'SolveBloc');
      }

      // 5Emit success
      emit(SolveSuccessState(mathForState));
      developer.log('SolveSuccessState emitted', name: 'SolveBloc');
    } catch (e, stackTrace) {
      developer.log('Error in _onSolveSubmitted: $e\n$stackTrace', name: 'SolveBloc', error: e);
      emit(SolveErrorState(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<SolveState> emit,
  ) async {
    try {
      // Toggle the favorite status
      final updatedMath = event.math.copyWith(
        isFavorite: !event.math.isFavorite,
      );

      // Update in the database
      await mathUseCase.update(updatedMath);

      // If current state is SolveSuccessState, update it with the new math
      if (state is SolveSuccessState) {
        emit(SolveSuccessState(updatedMath));
      }
    } catch (e) {
      developer.log('Error toggling favorite: $e', name: 'SolveBloc');
      // Optionally emit an error state or handle the error
    }
  }
}
