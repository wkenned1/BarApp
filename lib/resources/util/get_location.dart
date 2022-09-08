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
            LatLng? userLocation = await _getUserPosition();
            if (userLocation != null) {
              /*final locations = new List.from(Locations.defaultBars)
                ..addAll(Locations.defaultClubs);*/
              final locations = new List.from(getDefaultBars())
                ..addAll(getDefaultClubs());
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
  print("getUserLocation1");
  // Check if location service is enable
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }
  print("getUserLocation2");
  // Check if permission is granted
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }
  print("getUserLocation3");
  //final _locationData = await location.getLocation();
  var _locationData = await Future.any([
    location.getLocation(),
    Future.delayed(Duration(milliseconds: 500), () => null),
  ]);
  if (_locationData == null) {
    _locationData = await location.getLocation();
  }

  if(_locationData == null) {
    return null;
  }

  print("getUserLocation5");
  LocationUtil util = LocationUtil();
  util.setUserLocation(_locationData!);
  if (util.getUserLocation() == null) {
    return null;
  }
  if (util.getUserLocation()?.latitude == null ||
      util.getUserLocation()?.longitude == null) {
    return null;
  }
  print("getUserLocation4");
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

List<LocationModel> getDefaultBars() {
  return <LocationModel>[
    LocationModel(
        markerId: "Fenway Johnnie's",
        position: LatLng(42.346111, -71.099281),
        infoWindowTitle: "Fenway Johnnie's",
        address: "96 Brookline Ave, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Loretta's",
        position: LatLng(42.347328, -71.094490),
        infoWindowTitle: "Loretta's",
        address: "1 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Game On",
        position: LatLng(42.347031, -71.098389),
        infoWindowTitle: "Game On!",
        address: "82 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "OHE",
        position: LatLng(42.341782, -71.087357),
        infoWindowTitle: "OHE",
        address: "52 Gainsborough St, Boston, MA 02115",
        type: "bar"),
    LocationModel(
        markerId: "Lansdowne Pub",
        position: LatLng(42.347359, -71.095078),
        infoWindowTitle: "Lansdowne Pub",
        address: "9 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Ned Divine's",
        position: LatLng(42.360040, -71.056240),
        infoWindowTitle: "Ned Divine's",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Bell in Hand",
        position: LatLng(42.361519, -71.057053),
        infoWindowTitle: "Bell in Hand",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Sissy K’s",
        position: LatLng(42.359600, -71.053818),
        infoWindowTitle: "Sissy K’s",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Wild Rover",
        position: LatLng(42.359570, -71.053978),
        infoWindowTitle: "Wild Rover",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Scholars",
        position: LatLng(42.357738, -71.059067),
        infoWindowTitle: "Scholars",
        address: "25 School St, Boston, MA 02108",
        type: "bar"),
    LocationModel(
        markerId: "Hong Kong",
        position: LatLng(42.359558, -71.054108),
        infoWindowTitle: "Hong Kong",
        address: "65 Chatham St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "The Greatest Bar",
        position: LatLng(42.364620, -71.061363),
        infoWindowTitle: "The Greatest Bar",
        address: "262 Friend St, Boston, MA 02114",
        type: "bar"),
    LocationModel(
        markerId: "Lincoln Tavern",
        position: LatLng(42.336349, -71.047539),
        infoWindowTitle: "Lincoln Tavern",
        address: "425 W Broadway, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Loco",
        position: LatLng(42.337060, -71.047690),
        infoWindowTitle: "Loco",
        address: "412 W Broadway, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Capo",
        position: LatLng(42.336079, -71.047020),
        infoWindowTitle: "Capo",
        address: "443 W Broadway, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Fat Baby",
        position: LatLng(42.335030, -71.046230),
        infoWindowTitle: "Fat Baby",
        address: "118 Dorchester St, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Stats",
        position: LatLng(42.335810, -71.045320),
        infoWindowTitle: "Stats",
        address: "77 Dorchester St, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Playwrights",
        position: LatLng(42.335789, -71.038094),
        infoWindowTitle: "Playwrights",
        address: "658 E Broadway, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Publico",
        position: LatLng(42.337200, -71.043587),
        infoWindowTitle: "Publico",
        address: "11 Dorchester St, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "L Street Tavern",
        position: LatLng(42.331638, -71.035461),
        infoWindowTitle: "L Street Tavern",
        address: "658 E 8th St, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "The Broadway",
        position: LatLng(42.335918, -71.036232),
        infoWindowTitle: "The Broadway",
        address: "726 E Broadway, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Shenanigans",
        position: LatLng(42.338409, -71.049850),
        infoWindowTitle: "Shenanigans",
        address: "332 W Broadway, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Sunset Cantina",
        position: LatLng(42.350910, -71.116860),
        infoWindowTitle: "Sunset Cantina",
        address: "916 Commonwealth Ave, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Tits",
        position: LatLng(42.353250, -71.132560),
        infoWindowTitle: "Tits",
        address: "161 Brighton Ave, Boston, MA 02134",
        type: "bar"),
    LocationModel(
        markerId: "Buren",
        position: LatLng(42.395401, -71.121696),
        infoWindowTitle: "Buren",
        address: "247 Elm St, Somerville, MA 02144",
        type: "bar"),
    LocationModel(
        markerId: "The Pub",
        position: LatLng(42.399590, -71.111850),
        infoWindowTitle: "The Pub",
        address: "682 Broadway, Somerville, MA 02144",
        type: "bar"),
  ];
}

List<LocationModel> getDefaultClubs() {
  return <LocationModel>[
    LocationModel(
        markerId: "Bijou",
        position: LatLng(42.351238, -71.064209),
        infoWindowTitle: "Bijou",
        address: "51 Stuart St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Hava",
        position: LatLng(42.350731, -71.064728),
        infoWindowTitle: "Hava",
        address: "246 Tremont St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Venu",
        position: LatLng(42.350685, -71.066261),
        infoWindowTitle: "Venu",
        address: "100 Warrenton St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "The Tunnel",
        position: LatLng(42.350842, -71.065659),
        infoWindowTitle: "The Tunnel",
        address: "100 Stuart St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "The Grand",
        position: LatLng(42.353130, -71.047218),
        infoWindowTitle: "The Grand",
        address: "58 Seaport Blvd #300, Boston, MA 02210",
        type: "night_club"),
    LocationModel(
        markerId: "Royale",
        position: LatLng(42.349953, -71.065659),
        infoWindowTitle: "Royale",
        address: "279 Tremont St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Empire",
        position: LatLng(42.353180, -71.045227),
        infoWindowTitle: "Empire",
        address: "1 Marina Park Drive, Boston, MA 02210",
        type: "night_club"),
    LocationModel(
        markerId: "Icon",
        position: LatLng(42.350685, -71.066261),
        infoWindowTitle: "Icon",
        address: "100 Warrenton St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Memoire",
        position: LatLng(42.395351, -71.070190),
        infoWindowTitle: "Memoire",
        address: "1 Broadway, Everett, MA 02149",
        type: "night_club"),
    LocationModel(
        markerId: "Big Night Live",
        position: LatLng(42.365780, -71.060692),
        infoWindowTitle: "Big Night Live",
        address: "110 Causeway St, Boston, MA 02114",
        type: "night_club"),
  ];
}

