import 'package:flutter/cupertino.dart';

class Constants {
  static const title = "Bar App";
  static const kBlackColor = "0xFF000000";
  static const waitTimeReset = 60;
  static const imageExpiration = 24;

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
    //bars
    "OHE": "assets/images/customIcons/Icon_1.png", //OHE
    "Lansdowne Pub": "assets/images/customIcons/Icon_3.png", //landsdowne
    "Game On": "assets/images/customIcons/Icon_22.png", //game on
    "Sissy K’s": "assets/images/customIcons/Icon_24.png",
    "Fenway Johnnie's": "assets/images/customIcons/Icon_25.png",
    "Loretta's": "assets/images/customIcons/Icon_26.png",
    "Shenanigans": "assets/images/customIcons/Icon_27.png",
    "Lincoln Tavern": "assets/images/customIcons/Icon_29.png",
    "Fat Baby": "assets/images/customIcons/Icon_30.png",
    "Capo": "assets/images/customIcons/Icon_32.png",
    "Loco": "assets/images/customIcons/Icon_33.png",
    "Stats": "assets/images/customIcons/Icon_34.png",
    "Publico": "assets/images/customIcons/Icon_35.png",
    "The Broadway": "assets/images/customIcons/Icon_37.png",
    "Bell in Hand": "assets/images/customIcons/Icon_38.png",
    "Hong Kong": "assets/images/customIcons/Icon_39.png",
    "Wild Rover": "assets/images/customIcons/Icon_40.png",
    "Ned Divine's": "assets/images/customIcons/Icon_41.png",
    //clubs
    "Royale": "assets/images/customIcons/Icon_49.png",
    "Venu": "assets/images/customIcons/Icon_44.png",
    "Icon": "assets/images/customIcons/Icon_54.png",
    "The Tunnel": "assets/images/customIcons/Icon_55.png",
    "Hava": "assets/images/customIcons/Icon_56.png",
    "Bijou": "assets/images/customIcons/Icon_57.png",
  };

  static const customSmallIconsMap = {
    //bars
    "OHE": "assets/images/customIconsSmall/Icon_1.png", //OHE
    "Lansdowne Pub": "assets/images/customIconsSmall/Icon_3.png", //landsdowne
    "Game On": "assets/images/customIconsSmall/Icon_22.png", //game on
    "Sissy K’s": "assets/images/customIconsSmall/Icon_24.png",
    "Fenway Johnnie's": "assets/images/customIconsSmall/Icon_25.png",
    "Loretta's": "assets/images/customIconsSmall/Icon_26.png",
    "Shenanigans": "assets/images/customIconsSmall/Icon_27.png",
    "Lincoln Tavern": "assets/images/customIconsSmall/Icon_29.png",
    "Fat Baby": "assets/images/customIconsSmall/Icon_30.png",
    "Capo": "assets/images/customIconsSmall/Icon_32.png",
    "Loco": "assets/images/customIconsSmall/Icon_33.png",
    "Stats": "assets/images/customIconsSmall/Icon_34.png",
    "Publico": "assets/images/customIconsSmall/Icon_35.png",
    "The Broadway": "assets/images/customIconsSmall/Icon_37.png",
    "Bell in Hand": "assets/images/customIconsSmall/Icon_38.png",
    "Hong Kong": "assets/images/customIconsSmall/Icon_39.png",
    "Wild Rover": "assets/images/customIconsSmall/Icon_40.png",
    "Ned Divine's": "assets/images/customIconsSmall/Icon_41.png",
    //clubs
    "Royale": "assets/images/customIconsSmall/Icon_49.png",
    "Venu": "assets/images/customIconsSmall/Icon_44.png",
    "Icon": "assets/images/customIconsSmall/Icon_54.png",
    "The Tunnel": "assets/images/customIconsSmall/Icon_55.png",
    "Hava": "assets/images/customIconsSmall/Icon_56.png",
    "Bijou": "assets/images/customIconsSmall/Icon_57.png",
  };

  //time codes for wait times
  static const offHoursClosedCode = 0;
  static const showZeroMinCode = 1;
  static const onHoursCode = 2;
  static const offHoursNoneCode = 3;
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