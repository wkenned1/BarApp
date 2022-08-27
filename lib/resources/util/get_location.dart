import 'dart:convert';

import 'package:Linez/constants.dart';
import 'package:Linez/resources/util/get_distance.dart';
import 'package:geolocator/geolocator.dart' as Geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../globals.dart';
import '../../models/location_model.dart';
import '../../ui/map_test.dart';
import '../services/notification_service.dart';
import 'location_util.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        final prefs = await SharedPreferences.getInstance();
        int? ts = prefs.getInt(Constants.notificationLastSentTime);
        bool sendNotification = false;
        if (ts != null) {
          final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts);
          if (prev_ts.difference(DateTime.now()).inHours > 7) {
            sendNotification = true;
          }
        } else {
          sendNotification = true;
        }
        if (sendNotification) {
          //check if the current time is within the allowed range for sending notifications
          int hour = DateTime.now().hour;
          int weekday = DateTime.now().weekday;
          if ((hour >= 20 &&
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
            LatLng? userLocation = await _getUserPosition();
            if (userLocation != null) {
              final locations = new List.from(Locations.defaultBars)
                ..addAll(Locations.defaultClubs);
              LocationModel? shortestLocation = null;
              double shortestDistance = double.infinity;
              for (LocationModel location in locations) {
                double temp = calculateDistanceMeters(
                    userLocation.latitude,
                    userLocation.longitude,
                    location.position.latitude,
                    location.position.longitude);
                if (temp < shortestDistance) {
                  shortestDistance = temp;
                  shortestLocation = location;
                }
              }
              if (shortestLocation != null) {
                if (shortestDistance <= Constants.distanceToBarRequirement) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString(
                      Constants.notifiedBarMarkerId, shortestLocation.markerId);
                  prefs.setDouble(Constants.notifiedBarLatitude,
                      shortestLocation.position.latitude);
                  prefs.setDouble(Constants.notifiedBarLongitude,
                      shortestLocation.position.longitude);
                  prefs.setString(Constants.notifiedBarInfoWindowTitle,
                      shortestLocation.infoWindowTitle);
                  prefs.setString(
                      Constants.notifiedBarAddress, shortestLocation.address);
                  prefs.setString(
                      Constants.notifiedBarType, shortestLocation.type);
                  NotificationService().showNotification(
                      1,
                      "Near ${shortestLocation.markerId}? What's the wait?",
                      "Click to report wait the time",
                      1);
                }
              }
            } else {}
          } else {}
        }
        break;
    }
    return Future.value(true);
  });
}

Future<LatLng?> getUserLocation() async {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Location location = Location();
  // Check if location service is enable
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }
  // Check if permission is granted
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }
  final _locationData = await location.getLocation();
  LocationUtil util = LocationUtil();
  util.setUserLocation(_locationData);
  if (util.getUserLocation() == null) {
    return null;
  }
  if (util.getUserLocation()?.latitude == null ||
      util.getUserLocation()?.longitude == null) {
    return null;
  }
  return LatLng(
      util.getUserLocation()!.latitude, util.getUserLocation()!.longitude);
}

Future<LatLng?> _getUserPosition() async {
  try {
    Geo.Position userLocation = await Geo.Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: Geo.LocationAccuracy.high);
    return LatLng(userLocation.latitude, userLocation.longitude);
  } catch (e) {
    return null;
  }
}
