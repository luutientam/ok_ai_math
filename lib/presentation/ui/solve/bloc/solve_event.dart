// ignore_for_file: public_member_api_docs

import 'dart:typed_data';
import 'package:equatable/equatable.dart';

import '../../../../domain/models/math.dart';

abstract class SolveEvent extends Equatable {
  const SolveEvent();

  @override
  List<Object?> get props => [];
}

class SolveSubmittedEvent extends SolveEvent {
  final Uint8List imageBytes;
  final bool updateDb; // true = insert/update DB, false = chỉ UI
  final String? existingUid; // nếu solve lại, truyền uid cũ
  final bool isFavorite;

  const SolveSubmittedEvent(this.imageBytes, {this.updateDb = true, this.existingUid, this.isFavorite = false});
  
  @override
  List<Object?> get props => [imageBytes, updateDb, existingUid];
}

class ToggleFavoriteEvent extends SolveEvent {
  final Math math;
  
  const ToggleFavoriteEvent(this.math);
  
  @override
  List<Object?> get props => [math];
}

class SolveResetEvent extends SolveEvent {}
// load math từ id
class LoadMathByIdEvent extends SolveEvent {
  final int id;
  const LoadMathByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}