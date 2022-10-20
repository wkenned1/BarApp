import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/location_model.dart';

class Locations {
  static List<LocationModel> defaultBars = [];
  static List<LocationModel> defaultClubs = [];
}

class AppInfo {
  static DateTime? giveawayDate;
}

class UserData {
  static int userTickets = -1;
  static bool winner = false;
  static bool feedbackTicketReceived = false;
  static String winnerMessage = "";
  static List<String> reportedLocations = [];
  static bool showDisclaimerPopup = false;
  static bool admin = false;

  //drivers
  static bool driver = false;
  static String driverId = "";
}
