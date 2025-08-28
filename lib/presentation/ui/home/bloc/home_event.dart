class HomeEvent {}

class HomeLoadEvent extends HomeEvent {}

class HomeErrorEvent extends HomeEvent {
  final String message;

  HomeErrorEvent(this.message);
}
