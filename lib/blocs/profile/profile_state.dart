part of 'profile_bloc.dart';

@immutable
abstract class ProfileState extends Equatable {}

class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

class ProfileUpdatedState extends ProfileState {
  final ProfileModel profile;

  ProfileUpdatedState({required this.profile});

  @override
  List<Object> get props => [profile.tickets, profile.feedbackTicketReceived, profile.winnerMessage, profile.winner];
}
