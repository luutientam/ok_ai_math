class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<String> items;

  HomeLoaded(this.items);
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
