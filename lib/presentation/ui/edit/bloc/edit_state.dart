import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum EditStatus { initial, cropping, success, failure, canceled }

class EditState extends Equatable {
  final EditStatus status;
  final Uint8List? bytes;
  final String? error;

  const EditState({
    required this.status,
    this.bytes,
    this.error,
  });

  factory EditState.initial() => const EditState(status: EditStatus.initial);

  EditState copyWith({
    EditStatus? status,
    Uint8List? bytes,
    String? error,
    bool clearBytes = false,
    bool clearError = false,
  }) {
    return EditState(
      status: status ?? this.status,
      bytes: clearBytes ? null : (bytes ?? this.bytes),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, bytes, error];
}