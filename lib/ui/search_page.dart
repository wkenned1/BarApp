import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
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
import 'package:url_launcher/url_launcher.dart';
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
    //initBackgroundTracking();
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

  Future<void> _disableDisclaimerPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.termsOfServicePopupShown, true);
  }

  //show popup on when app is first opened
  Widget _buildDisclaimerDialog(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.black, fontSize: 20.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    _disableDisclaimerPopup();
    return new AlertDialog(
      //title: const Text("Congrats! You won this month's giveaway!"),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              TextSpan(text: "By continuing you accept Linez App's "),
              TextSpan(
                  text: 'Terms of Service',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://linezapp.com/terms_conditions.html';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'Could not launch $url';
                      }
                    }),
              TextSpan(text: ' and our '),
              TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://linezapp.com/privacy.html';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'Could not launch $url';
                      }
                    }),
            ],
          )),
          //Text("By continuing you accept Linez App's terms of service and privacy policy."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }

  //start background process for sending notifications and tracking location
  /*Future<void> initBackgroundTracking() async {
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
  }*/

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
    //get location

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? disclaimerShown = prefs.getBool(Constants.termsOfServicePopupShown);
    if(disclaimerShown != null) {
      if(!disclaimerShown) {
        UserData.showDisclaimerPopup = true;
      }
      else {
        UserData.showDisclaimerPopup = false;
      }
    }
    else {
      UserData.showDisclaimerPopup = true;
    }

    if(UserData.showDisclaimerPopup) {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildDisclaimerDialog(context));
    }

    AppInfo.giveawayDate = await DatabaseService().getGiveawayTime();
    await _getUserLocation();
    if(UserData.winner && UserData.winnerMessage != Constants.winnerMessageAfterPopup){
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildWinnerDialog(context));
    }

    //get user info
    /*ProfileModel? profile = await DatabaseService().getUserProfile();
    if(profile != null) {
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
    });
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
          //color: Color(Constants.boxBlue),
          child: FutureBuilder<void>(
              future: _initFunction(context)/*_getUserLocation()*/,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                    new ClickableSectionsWidget(
                      sectionTitle: "Bars",
                      body: ClickableLocationsList(
                      locations: barLocations,
                      userLocation: userLocation)),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
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

