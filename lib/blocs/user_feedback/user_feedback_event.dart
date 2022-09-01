part of 'user_feedback_bloc.dart';

@immutable
abstract class UserFeedbackEvent {}

class FeedbackSubmitted extends UserFeedbackEvent {
  final String message;
  FeedbackSubmitted({required this.message});
}
