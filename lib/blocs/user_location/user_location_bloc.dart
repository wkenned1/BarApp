import 'dart:async';

import 'package:Linez/resources/util/get_location.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'user_location_event.dart';
part 'user_location_state.dart';

class UserLocationBloc extends Bloc<UserLocationEvent, UserLocationState> {
  UserLocationBloc() : super(UserLocationInitial()) {
    on<GetLocationEvent>(_getUserLocation);
  }

  _getUserLocation(event, emit) async {
    print("G LOCATION");
    LatLng? location = await getUserLocation();
    print("G LOCATION 1");
    if(location == null) {
      print("G LOCATION 2");
      emit(UserLocationInitial());
    }
    else {
      print("G LOCATION 3");
      emit(UserLocationUpdate(location: location));
    }
  }
}
