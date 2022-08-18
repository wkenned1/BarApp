import 'package:geolocator/geolocator.dart' as Geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';

import 'location_util.dart';

const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  print("CALLBACk DISPATCHER");
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        print("CALLBACk DISPATCHER2");
        //LatLng? userLocation = await _getUserLocation();
        LatLng? userLocation = await _getUserPosition();
        if (userLocation != null) {
          print(
              "LOCATION: ${userLocation.latitude}, ${userLocation.longitude}");
        } else {
          print("location: null");
        }
        break;
    }
    return Future.value(true);
  });
}

Future<LatLng?> _getUserLocation() async {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Location location = Location();
  print("getting loc 1");
  // Check if location service is enable
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }
  print("getting loc 2");
  // Check if permission is granted
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }
  print("getting loc 3");
  final _locationData = await location.getLocation();
  LocationUtil util = LocationUtil();
  util.setUserLocation(_locationData);
  print(
      "RESULT: ${util.getUserLocation()?.latitude}, ${util.getUserLocation()?.longitude}");
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
    print("GEOLOCATOR ERROR: ${e.toString()}");
    return null;
  }
}
