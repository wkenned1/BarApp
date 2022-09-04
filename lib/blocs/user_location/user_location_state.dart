part of 'user_location_bloc.dart';

@immutable
abstract class UserLocationState {}

class UserLocationInitial extends UserLocationState {}

class UserLocationUpdate extends UserLocationState {
  final LatLng location;
  UserLocationUpdate({required this.location});
}
