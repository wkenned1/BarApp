import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../globals.dart';
import '../../main.dart';
import '../../resources/repositories/database_repository_impl.dart';
import '../../resources/util/get_distance.dart';
import '../../resources/util/get_location.dart';

part 'line_image_event.dart';
part 'line_image_state.dart';

class LineImageBloc extends Bloc<LineImageEvent, LineImageState> {
  final StorageRepository _storageRepository;
  final DatabaseRepository _databaseRepository;

  LineImageBloc(this._storageRepository, this._databaseRepository) : super(LineImageInitial()) {
    on<LineImageSubmit>(_submitImage);
  }

  /*_submitImage(event, emit) async {
    emit(LineImageLoading());

    final prefs = await SharedPreferences.getInstance();
    int? ts = prefs.getInt(event.address + "-img");
    //check if user reported this bar previously
    if (ts != null) {
      final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts).toUtc();
      if (prev_ts
          .difference(DateTime.now().toUtc())
          .inMinutes.abs() <
          Constants.waitTimeReset) {
        emit(LineImageIntervalError());
        return;
      }
    }

    bool result = await _storageRepository.submitLineImage(event.imagePath, event.address);
    if(result) {
      int timestamp = DateTime
          .now()
          .toUtc()
          .millisecondsSinceEpoch;
      prefs.setInt(event.address + "-img", timestamp);
      emit(LineImageSubmitted());
    }
    else {
      emit(LineImageError(message: "Something went wrong"));
    }
  }*/

  _submitImage(
      event, emit) async {

    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null){
      if(UserData.admin == true) {
        final prefs = await SharedPreferences.getInstance();
        bool result = await _storageRepository.submitLineImage(event.imagePath, event.id);
        if(result) {
          int timestamp = DateTime
              .now()
              .toUtc()
              .millisecondsSinceEpoch;
          prefs.setInt(event.id + "-img", timestamp);
          await _databaseRepository.addReportedLocation(event.id);
          UserData.reportedLocations.add(event.id);
          emit(LineImageSubmitted());
        }
        else {
          emit(LineImageError(message: "Something went wrong"));
        }
        return;
      }
    }

    //restrictions will be disabled during app review
    //when restrictions are disabled users can submit wait times at any time and from any location
    bool restrictionsDisabled = await _databaseRepository.getRestrictionMode();
    print("working 1");
    if (Platform.isIOS) {
      final accuracyStatus = await Geolocator.getLocationAccuracy();
      if(!restrictionsDisabled) {
        switch(accuracyStatus) {
          case LocationAccuracyStatus.reduced:
          // Precise location switch is OFF.
            emit(LineImageImpreciseLocationError());
            return;
        /*case LocationAccuracyStatus.precise:
      // Precise location switch is ON.
        break;*/
          case LocationAccuracyStatus.unknown:
            emit(LineImageImpreciseLocationError());
            return;
        }
      }
    }
    print("working 2");

    int hour = DateTime.now().hour;
    int weekday = DateTime.now().weekday;
    int dtCode = checkDateTime(hour, weekday);

    print("working 3");

    //check if day and time is correct
    if (restrictionsDisabled || dtCode == Constants.onHoursCode || dtCode == Constants.showZeroMinCode) {
      print("working 4");
      try {
        final prefs = await SharedPreferences.getInstance();
        int? ts = prefs.getInt(event.id+ "-img");
        //check if user reported this bar previously
        if (ts != null) {
          final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts).toUtc();
          if (prev_ts
              .difference(DateTime.now().toUtc())
              .inMinutes.abs() <
              Constants.waitTimeReset) {
            emit(LineImageIntervalError());
            return;
          }
        }
        print("working 5");
        if(!restrictionsDisabled) {
          //checking location requirements
          LatLng? userLoc = await getUserLocation();
          if(userLoc == null){
            emit(LineImageNoLocationError());
            return;
          }
          double distance = calculateDistanceMeters(
              userLoc.latitude,
              userLoc.longitude,
              event.location.latitude,
              event.location.longitude);
          //if user is too far away from bar
          if(distance > Constants.distanceToBarRequirement){
            emit(LineImageLocationError());
            return;
          }
        }
        print("working 6");
        bool result = await _storageRepository.submitLineImage(event.imagePath, event.id);
        print("working 7 ${result}");
        if(result) {
          int timestamp = DateTime
              .now()
              .toUtc()
              .millisecondsSinceEpoch;
          prefs.setInt(event.id + "-img", timestamp);
          await _databaseRepository.addReportedLocation(event.id);
          UserData.reportedLocations.add(event.id);
          emit(LineImageSubmitted());
        }
        else {
          emit(LineImageError(message: "Something went wrong"));
        }
      } catch (e) {
        emit(LineImageError(message: "Something went wrong"));
      }
    }
    else {
      emit(LineImageTimeError(hour: hour, weekday: weekday));
    }
  }
}
