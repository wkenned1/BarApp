part of 'line_image_bloc.dart';

@immutable
abstract class LineImageState {}

class LineImageInitial extends LineImageState {}

class LineImageLoading extends LineImageState {}

class LineImageSubmitted extends LineImageState {}

class LineImageIntervalError extends LineImageState {
}

class LineImageImpreciseLocationError extends LineImageState {
}

class LineImageTimeError extends LineImageState {
  final int hour;
  final int weekday;

  LineImageTimeError({required this.hour, required this.weekday});
}

class LineImageNoLocationError extends LineImageState {
}

class LineImageLocationError extends LineImageState {
}

class LineImageError extends LineImageState {
  final String message;

  LineImageError({required this.message});
}
