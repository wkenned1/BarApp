import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../globals.dart';
import '../../models/profile_model.dart';
import '../../resources/repositories/database_repository_impl.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final DatabaseRepository _databaseRepository;

  ProfileBloc(this._databaseRepository) : super(ProfileInitial()) {
    on<GetProfileEvent>(_getProfile);
  }

  _getProfile(event, emit) async {
    ProfileModel? profile = await _databaseRepository.getUserProfile();
    if(profile != null) {
      UserData.userTickets = profile.tickets;
      UserData.winner = profile.winner;
      UserData.feedbackTicketReceived = profile.feedbackTicketReceived;
      UserData.winnerMessage = profile.winnerMessage;
      UserData.reportedLocations = profile.reportedLocations;
      print("PROFILE TICKETS: ${profile.tickets} !!!!!!!!!!!!!!!!!!");
      emit(ProfileUpdatedState(profile: profile));
    }
  }
}


