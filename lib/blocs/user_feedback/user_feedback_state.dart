part of 'user_feedback_bloc.dart';

@immutable
abstract class UserFeedbackState {}

class UserFeedbackInitial extends UserFeedbackState {}

class UserFeedbackSuccess extends UserFeedbackState {
}

class UserFeedbackFailure extends UserFeedbackState {
  final String errorMessage;
  UserFeedbackFailure({required this.errorMessage});
}