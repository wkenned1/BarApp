import 'dart:math';

import 'package:bar_app/ui/bar_page.dart';
import 'package:bar_app/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_model.dart';
import '../resources/util/get_location.dart';
import '../resources/util/location_util.dart';
import 'map_test.dart';
import 'package:location/location.dart';
import 'package:notification_permissions/notification_permissions.dart'
    as NotificationPermissions;
import 'package:workmanager/workmanager.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Future<void> _getUserLocation() async {
    print("FINDING LOCATION");
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    LocationUtil util = LocationUtil();
    util.setUserLocation(_locationData);

    initBackgroundTracking();

    print(
        "RESULT: ${util.getUserLocation()?.latitude}, ${util.getUserLocation()?.longitude}");
  }

  Future<void> initBackgroundTracking() async {
    /*final notificationPermissions = await NotificationPermissions
        .NotificationPermissions.getNotificationPermissionStatus();
    if (notificationPermissions == PermissionStatus.granted ||
        notificationPermissions == PermissionStatus.grantedLimited) {*/
    print("one");
    Workmanager manager = Workmanager();
    manager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    print("two");
    manager.registerPeriodicTask(
      "1",
      fetchBackground,
      frequency: Duration(minutes: 30),
    );
    print("three");
    /*} else {
      final permissionStatus = await NotificationPermissions
          .NotificationPermissions.requestNotificationPermissions();
    }*/
  }

  String calculateDistanceMiles(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (0.621371 * 12742 * asin(sqrt(a))).toStringAsFixed(1);
  }

  Widget clickableLocation(
      LocationModel location, LatLng? userLocation, BuildContext context) {
    print("LOC ${userLocation?.longitude}, ${userLocation?.latitude}");
    return GestureDetector(
      child: Column(
        children: [
          Center(
            child: Text(location.markerId, style: TextStyle(fontSize: 25)),
          ),
          Center(child: Text(location.address, style: TextStyle(fontSize: 15))),
          if (userLocation?.longitude != null && userLocation?.latitude != null)
            Text(
                "${calculateDistanceMiles(userLocation?.latitude, userLocation?.longitude, location.position.latitude, location.position.longitude)} miles away"),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BarPage(location: location)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<LocationModel> locations = getDefaultLocations();
    //await _getUserLocation();
    LocationUtil userLocation = LocationUtil();
    return Container(
        /*Column(
      children: <Widget>[
        for (var location in locations)
          clickableLocation(location, userLocation.getUserLocation(), context)
      ],
    )*/
        child: FutureBuilder<void>(
            future: _getUserLocation(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return Column(children: [
                //GetLocationWidget(),
                Column(
                  children: <Widget>[
                    for (var location in locations)
                      clickableLocation(
                          location, userLocation.getUserLocation(), context)
                  ],
                )
              ]);
            }));
  }
}
