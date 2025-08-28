import 'package:equatable/equatable.dart';

abstract class FavoritesPhotoEvent extends Equatable {
  const FavoritesPhotoEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesPhoto extends FavoritesPhotoEvent {}