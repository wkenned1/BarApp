import 'dart:async';

import 'package:Linez/constants.dart';
import 'package:Linez/globals.dart';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/repositories/database_repository_impl.dart';
import '../../resources/util/get_distance.dart';
import '../../resources/util/get_location.dart';
import '../get_wait_time/wait_time_bloc.dart';
import 'dart:io' show Platform;

part 'wait_time_report_event.dart';
part 'wait_time_report_state.dart';

class WaitTimeReportBloc
    extends Bloc<WaitTimeReportEvent, WaitTimeReportState> {
  final DatabaseRepository _databaseRepository;

  WaitTimeReportBloc(this._databaseRepository)
      : super(WaitTimeReportState(submitSuccessful: false, loading: false)) {
    on<WaitTimeReportEvent>(_reportWaitTime);
  }

  _reportWaitTime(
      WaitTimeReportEvent event, Emitter<WaitTimeReportState> emit) async {
    emit(WaitTimeReportState(submitSuccessful: false, loading: true));

    if (Platform.isIOS) {
      final accuracyStatus = await Geolocator.getLocationAccuracy();
      switch(accuracyStatus) {
        case LocationAccuracyStatus.reduced:
        // Precise location switch is OFF.
          emit(WaitTimeReportState(submitSuccessful: false, loading: false, errorMessage: Constants.waitTimeImpreciseLocationError));
          return;
      /*case LocationAccuracyStatus.precise:
      // Precise location switch is ON.
        break;*/
        case LocationAccuracyStatus.unknown:
          emit(WaitTimeReportState(submitSuccessful: false, loading: false, errorMessage: Constants.waitTimeImpreciseLocationError));
          return;
      }
    }

    int hour = DateTime.now().hour;
    int weekday = DateTime.now().weekday;
    print("Weekday: ${weekday}, Hour: ${hour}");
    //check if day and time is correct
    if (true || (hour >= 20 &&
        hour <= 23 &&
        (weekday == 4 ||
            weekday == 5 ||
            weekday == 6 ||
            weekday == 7)) ||
        (hour > 0 &&
            hour <= 2 &&
            (weekday == 5 ||
                weekday == 6 ||
                weekday == 7 ||
                weekday == 1))) {
      try {
        final prefs = await SharedPreferences.getInstance();
        int? ts = prefs.getInt(event.address);
        //check if user reported this bar previously
        if (ts != null) {
          final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts).toUtc();
          if (prev_ts
              .difference(DateTime.now().toUtc())
              .inMinutes <
              Constants.waitTimeReset) {
            print("ERROR");
            emit(WaitTimeReportState(
                submitSuccessful: false,
                loading: false,
                errorMessage:
                Constants.waitTimeReportIntervalError));
            return;
          }
        }

        //checking location requirements
        LatLng? userLoc = await getUserLocation();
        if(userLoc == null){
          emit(WaitTimeReportState(
              submitSuccessful: false,
              loading: false,
              errorMessage:
              Constants.waitTimeReportNoLocationError));
          return;
        }
        double distance = calculateDistanceMeters(
            userLoc.latitude,
            userLoc.longitude,
            event.location.latitude,
            event.location.longitude);
        //if user is too far away from bar
        print("distance: ${distance}");
        if(distance > Constants.distanceToBarRequirement && false){
          emit(WaitTimeReportState(
              submitSuccessful: false,
              loading: false,
              errorMessage:
              Constants.waitTimeReportLocationError));
          return;
        }

        await _databaseRepository.addWaitTime(event.address, event.waitTime);
        int timestamp = DateTime
            .now()
            .toUtc()
            .millisecondsSinceEpoch;
        prefs.setInt(event.address, timestamp);
        print("WORKED");
        _databaseRepository.addReportedLocation(event.address);
        UserData.reportedLocations.add(event.address);
        emit(WaitTimeReportState(submitSuccessful: true, loading: false));
      } catch (e) {
        print("ERROR 2");
        emit(WaitTimeReportState(
            submitSuccessful: false,
            loading: false,
            errorMessage: e.toString()));
      }
    }
    else {
      emit(WaitTimeReportState(submitSuccessful: false, errorMessage: Constants.waitTimeReportTimeError, loading: false));
    }
  }
}
