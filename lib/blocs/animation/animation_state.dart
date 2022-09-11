part of 'animation_bloc.dart';

@immutable
abstract class AnimationState {}

class AnimationInitial extends AnimationState {
}

class BounceAnimationState extends AnimationState {
  final int durationMillis;

  BounceAnimationState({required this.durationMillis});
}
