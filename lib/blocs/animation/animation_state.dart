part of 'animation_bloc.dart';

@immutable
abstract class AnimationState {}

class AnimationInitial extends AnimationState {
}

class TicketAnimating extends AnimationState {

  TicketAnimating();
}
