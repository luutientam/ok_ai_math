import 'package:bloc/bloc.dart';
import 'package:cropperx/cropperx.dart';



import 'edit_event.dart';
import 'edit_state.dart';

class EditBloc extends Bloc<EditEvent, EditState> {
  EditBloc() : super(EditState.initial()) {
    on<EditCropRequested>(_onCropRequested);
    on<EditCancelRequested>(_onCancelRequested);
  }

  Future<void> _onCropRequested(
    EditCropRequested event,
    Emitter<EditState> emit,
  ) async {
    emit(state.copyWith(status: EditStatus.cropping, clearError: true));
    try {
      final bytes = await Cropper.crop(cropperKey: event.cropperKey);
      if (bytes == null) {
        emit(state.copyWith(
          status: EditStatus.failure,
          error: 'No crop result',
        ));
        return;
      }
      emit(state.copyWith(status: EditStatus.success, bytes: bytes));
    } catch (e) {
      emit(state.copyWith(status: EditStatus.failure, error: '$e'));
    }
  }

  void _onCancelRequested(
    EditCancelRequested event,
    Emitter<EditState> emit,
  ) {
    emit(state.copyWith(status: EditStatus.canceled, clearBytes: true));
  }
}