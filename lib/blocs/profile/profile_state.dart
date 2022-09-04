part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileUpdatedState extends ProfileState {
  final ProfileModel profile;

  ProfileUpdatedState({required this.profile});
}
