import 'package:equatable/equatable.dart';

import '../../../../domain/models/math.dart';

abstract class FavoritesPhotoState extends Equatable {
  const FavoritesPhotoState();

  @override
  List<Object?> get props => [];
}

class FavoritesPhotoInitial extends FavoritesPhotoState {}

class FavoritesPhotoLoading extends FavoritesPhotoState {}

class FavoritesPhotoLoaded extends FavoritesPhotoState {
  final List<Math> favorites;
  const FavoritesPhotoLoaded(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class FavoritesPhotoError extends FavoritesPhotoState {
  final String message;
  
  const FavoritesPhotoError(this.message);
  
  @override
  List<Object?> get props => [message];
}
