part of 'line_image_bloc.dart';

@immutable
abstract class LineImageEvent {}

class LineImageSubmit extends LineImageEvent {
  final String imagePath;
  final String id;

  LineImageSubmit({required this.imagePath, required this.id});
}
