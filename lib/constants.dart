import 'package:flutter/cupertino.dart';

class Constants {
  static const title = "Bar App";
  static const kBlackColor = "0xFF000000";
  static const waitTimeReset = 90;

  //color scheme
  static const waitTimeTextRed = 0xffff492b;
  static const waitTimeTextOrange = 0xfff99500;
  static const waitTimeTextGreen = 0xff2ac300;
  static const linezBlue = 0xff35558a;
  static const boxBlue = 0xff516fa2;
  //static const boxBlue = 0xff6183bc;
  static const submitButtonBlue = 0xff4285f4;

  //shared preferences keys
  static const notifiedBarMarkerId = "notifiedBarMarkerId";
  static const notifiedBarLatitude = "notifiedBarLatitude";
  static const notifiedBarLongitude = "notifiedBarLongitude";
  static const notifiedBarInfoWindowTitle = "notifiedBarInfoWindowTitle";
  static const notifiedBarAddress = "notifiedBarAddress";
  static const notifiedBarType = "notifiedBarType";
  static const notificationLastSentTime = "notificationLastSentTime";
  static const termsOfServicePopupShown = "termsOfServicePopupShown";

  //error codes
  static const waitTimeReportIntervalError = "INTERVAL";
  static const waitTimeReportTimeError = "TIME";
  static const waitTimeReportLocationError = "LOCATION";
  static const waitTimeReportNoLocationError = "NOLOCATION";
  static const waitTimeImpreciseLocationError = "IMPLOCATION";

  static const invalidPhoneNumber = "invalid-phone-number";
  static const genericError = "generic-error";

  //business logic
  static const distanceToBarRequirement = 100;

  //user related
  static const winnerMessageAfterPopup = "PopupShown";
  static const giveawayExplanation = "Linez App will reward you every time you submit a line estimate. Earn 1 ticket for each entry for a chance to win a \$100 Amazon gift card at the end of the giveaway. Each winner will be texted a link to redeem the gift card on amazon.com. Start earning tickets by signing up with your mobile phone!";
  static const giveawayDisclaimerIOS = "This giveaway is sponsored by Linez App and not Apple.";
  static const giveawayDisclaimerAndroid = "This giveaway is sponsored by Linez App and not the Google Play Store.";

  //location icons
  static const customIconsMap = {
    "OHE": "assets/images/ohe_icon.png", //OHE
    "Lansdowne Pub": "assets/images/landsdowne_icon.png", //landsdowne
    "Game On": "assets/images/game_on_icon.png", //game on
    "Sissy K’s": "assets/images/sissy_ks_icon.png",//sissy k's
  };

  static const customSmallIconsMap = {
    "OHE": "assets/images/ohe_icon_small.png", //OHE
    "Lansdowne Pub": "assets/images/landsdowne_icon_small.png", //landsdowne
    "Game On": "assets/images/game_on_icon_small.png", //game on
    "Sissy K’s": "assets/images/sissy_ks_icon_small.png",//sissy k's
  };
}

//permissions
enum PermissionGroup {
  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation - Always
  locationAlways,

  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation - WhenInUse
  locationWhenInUse
}