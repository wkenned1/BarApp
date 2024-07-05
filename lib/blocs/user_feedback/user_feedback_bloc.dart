import 'dart:async';

import 'package:Linez/globals.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../resources/repositories/database_repository_impl.dart';

part 'user_feedback_event.dart';
part 'user_feedback_state.dart';

class UserFeedbackBloc extends Bloc<UserFeedbackEvent, UserFeedbackState> {
  final DatabaseRepository _databaseRepository;

  UserFeedbackBloc(this._databaseRepository) : super(UserFeedbackInitial()) {
    on<FeedbackSubmitted>((event, emit) async {
      // TODO: implement event handler
      bool result = await _databaseRepository.sendFeedback(event.message);
      if(result) {
        if(!UserData.feedbackTicketReceived){
          UserData.feedbackTicketReceived = true;
          _databaseRepository.incrementTickets(fromFeedback: true);
        }
        emit(UserFeedbackSuccess());
      }
      else {
        emit(UserFeedbackFailure(errorMessage: "failure"));
      }
    });
  }
}
