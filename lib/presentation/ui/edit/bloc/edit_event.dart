  import 'package:equatable/equatable.dart';
  import 'package:flutter/widgets.dart';

  abstract class EditEvent extends Equatable {
    const EditEvent();

    @override
    List<Object?> get props => const [];
  }

  class EditCropRequested extends EditEvent {
    final GlobalKey cropperKey;
    const EditCropRequested(this.cropperKey);

    @override
    List<Object?> get props => [cropperKey];
  }

  class EditCancelRequested extends EditEvent {
    const EditCancelRequested();
  }