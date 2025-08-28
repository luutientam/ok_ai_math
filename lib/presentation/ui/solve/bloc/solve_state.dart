// ignore_for_file: public_member_api_docs


import '../../../../domain/models/math.dart';

abstract class SolveState {
  const SolveState();
}

class SolveInitialState extends SolveState {
  const SolveInitialState();
}

class SolveLoadingState extends SolveState {
  const SolveLoadingState();
}

class SolveSuccessState extends SolveState {
  final Math math;
  const SolveSuccessState(this.math);
}

class SolveErrorState extends SolveState {
  final String message;
  const SolveErrorState(this.message);
}