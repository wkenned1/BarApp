import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:Linez/blocs/profile/profile_bloc.dart';
import 'package:Linez/blocs/user_location/user_location_bloc.dart';
import 'package:Linez/main.dart';
import 'package:Linez/ui/bar_page.dart';
import 'package:Linez/ui/home_page.dart';
import 'package:Linez/ui/phone_sign_in_page.dart';
import 'package:Linez/ui/widgets/clickable_location_widget.dart';
import 'package:Linez/ui/widgets/clickable_sections_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../constants.dart';
import '../globals.dart';
import '../models/location_model.dart';
import '../models/profile_model.dart';
import '../resources/services/database_service.dart';
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

  //show popup on search page if the user won the givaway
  Widget _buildWinnerDialog(BuildContext context) {
    DatabaseService().disableWinnerPopup();
    return new AlertDialog(
      title: const Text("Congrats! You won this month's giveaway!"),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(UserData.winnerMessage),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
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

  Future<void> _initFunction(BuildContext context) async {
    print("init");
    //get location
    print("init1");
    AppInfo.giveawayDate = await DatabaseService().getGiveawayTime();
    print("init2");
    await _getUserLocation();
    //get user info
    print("CKECHING PROFILE");
    /*ProfileModel? profile = await DatabaseService().getUserProfile();
    if(profile != null) {
      print("PROFILE FOUND");
      UserData.userTickets = profile.tickets;
      UserData.winner = profile.winner;
      UserData.feedbackTicketReceived = profile.feedbackTicketReceived;
      UserData.winnerMessage = profile.winnerMessage;
      UserData.reportedLocations = profile.reportedLocations;
    }*/
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.getToken().then((token) {
      print('TOKEN: $token');
    });
    print("build");
    if (launchBarPage) {
      launchBarPage = false;
      pushBarPage(context);
    }
    //get location
    context.read<UserLocationBloc>().add(GetLocationEvent());

    List<LocationModel> barLocations = Locations.defaultBars;
    List<LocationModel> clubLocations = Locations.defaultClubs;
    //await _getUserLocation();
    LocationUtil userLocation = LocationUtil();
    return RefreshIndicator(
      //TODO: find a cleaner way to refresh the page
      onRefresh: () async {
        context.read<UserLocationBloc>().add(GetLocationEvent());
        (context as Element).reassemble();
      },
      child: Container(
          child: FutureBuilder<void>(
              future: _initFunction(context)/*_getUserLocation()*/,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if(UserData.winner && UserData.winnerMessage != Constants.winnerMessageAfterPopup){
                  Future.delayed(Duration.zero, () =>
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildWinnerDialog(context))
                  );

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

