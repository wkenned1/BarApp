import 'models/location_model.dart';

class Locations {
  static List<LocationModel> defaultBars = [];
  static List<LocationModel> defaultClubs = [];
}

class UserData {
  static int userTickets = -1;
  static bool winner = false;
  static bool feedbackTicketReceived = false;
  static String winnerMessage = "";
  static List<String> reportedLocations = [];
}
