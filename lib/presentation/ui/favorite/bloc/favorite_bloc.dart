import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../domain/models/math.dart';
import '../../../../domain/usecases/math_use_case.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoritesPhotoBloc extends Bloc<FavoritesPhotoEvent, FavoritesPhotoState> {
  final MathUseCase mathUseCase;


  FavoritesPhotoBloc({required this.mathUseCase}) : super(FavoritesPhotoInitial()) {
    on<LoadFavoritesPhoto>(_onLoadFavorites);
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesPhoto event, Emitter<FavoritesPhotoState> emit) async {
    emit(FavoritesPhotoLoading());
    try {
      final allItems = await mathUseCase.selectAll();
      final favorites = allItems.where((math) => math.isFavorite).toList();

      emit(FavoritesPhotoLoaded(favorites));
    } catch (e) {
      emit(FavoritesPhotoError('Failed to load favorites: $e'));
    }
  }
}
