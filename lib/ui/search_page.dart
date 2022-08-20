import 'dart:math';

import 'package:bar_app/main.dart';
import 'package:bar_app/ui/bar_page.dart';
import 'package:bar_app/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/location_model.dart';
import '../resources/util/get_distance.dart';
import '../resources/util/get_location.dart';
import '../resources/util/location_util.dart';
import 'map_test.dart';
import 'package:location/location.dart';
import 'package:notification_permissions/notification_permissions.dart'
    as NotificationPermissions;
import 'package:workmanager/workmanager.dart';

class SearchPage extends StatelessWidget {
  bool launchBarPage = false;
  SearchPage({Key? key}) : super(key: key) {
    //should set launchBarPage to true once
    if (appLaunchDetails != null) {
      if (appLaunchDetails!.didNotificationLaunchApp) {
        launchBarPage = true;
      }
    }
  }
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

  Future<void> pushBarPage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? markerId = prefs.getString(Constants.notifiedBarMarkerId);
    double? latitude = prefs.getDouble(Constants.notifiedBarLatitude);
    double? longitude = prefs.getDouble(Constants.notifiedBarLongitude);
    String? infoWindowTitle =
        prefs.getString(Constants.notifiedBarInfoWindowTitle);
    String? address = prefs.getString(Constants.notifiedBarAddress);
    String? type = prefs.getString(Constants.notifiedBarType);
    if (markerId != null &&
        latitude != null &&
        longitude != null &&
        infoWindowTitle != null &&
        address != null &&
        type != null) {
      LocationModel location = LocationModel(
          markerId: markerId,
          position: LatLng(latitude, longitude),
          infoWindowTitle: infoWindowTitle,
          address: address,
          type: type);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BarPage(location: location)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (launchBarPage) {
      launchBarPage = false;
      pushBarPage(context);
    }
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
