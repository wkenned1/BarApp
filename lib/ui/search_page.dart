import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:Linez/main.dart';
import 'package:Linez/ui/bar_page.dart';
import 'package:Linez/ui/home_page.dart';
import 'package:Linez/ui/phone_sign_in_page.dart';
import 'package:Linez/ui/widgets/clickable_location_widget.dart';
import 'package:Linez/ui/widgets/clickable_sections_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../constants.dart';
import '../globals.dart';
import '../models/location_model.dart';
import '../resources/services/notification_service.dart';
import '../resources/util/get_distance.dart';
import '../resources/util/get_location.dart';
import '../resources/util/location_util.dart';
import 'map_test.dart';
import 'package:location/location.dart';
import 'package:notification_permissions/notification_permissions.dart'
    as NotificationPermissions;
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  //check location permissions and get user location
  Future<void> _getUserLocation() async {
    print("location 1");
    Location location = Location();
    print("location 2");
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    print("location 3");
    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    print("location 4");
    final _locationData = await location.getLocation();
    print("!!!!!!!!!! Location: ${_locationData.latitude}, ${_locationData.longitude}");
    LocationUtil util = LocationUtil();
    util.setUserLocation(_locationData);

    initBackgroundTracking();
  }

  //start background process for sending notifications and tracking location
  Future<void> initBackgroundTracking() async {
    Workmanager manager = Workmanager();
    manager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    manager.registerPeriodicTask(
      "1",
      fetchBackground,
      frequency: Duration(minutes: 30),
    );
  }

  //navigate to bar page
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

    print("build");
    if (launchBarPage) {
      launchBarPage = false;
      pushBarPage(context);
    }
    List<LocationModel> barLocations = Locations.defaultBars;
    List<LocationModel> clubLocations = Locations.defaultClubs;
    //await _getUserLocation();
    LocationUtil userLocation = LocationUtil();
    return RefreshIndicator(
      //TODO: find a cleaner way to refresh the page
      onRefresh: () async {
        (context as Element).reassemble();
      },
      child: Container(
          child: FutureBuilder<void>(
              future: _getUserLocation(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if(userLocation.getUserLocation() == null){
                  print("LOC NULL");
                }
                else {
                  print("USER LOCATION: ${userLocation.getUserLocation()!.latitude}, ${userLocation.getUserLocation()!.latitude}");
                }
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    new ClickableSectionsWidget(
                        sectionTitle: "Bars",
                        body: ClickableLocationsList(
                            locations: barLocations,
                            userLocation: userLocation)),
                    new ClickableSectionsWidget(
                        sectionTitle: "Clubs",
                        body: ClickableLocationsList(
                            locations: clubLocations,
                            userLocation: userLocation))
                  ],
                ));
              })),
    );
  }
}

