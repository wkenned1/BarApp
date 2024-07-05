part of 'user_location_bloc.dart';

@immutable
abstract class UserLocationState extends Equatable {}

class UserLocationInitial extends UserLocationState {
  @override
  List<Object> get props => [];
}

class UserLocationUpdate extends UserLocationState {
  final LatLng location;
  UserLocationUpdate({required this.location});

  @override
  List<Object> get props => [this.location];
}
