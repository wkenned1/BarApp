import 'package:flutter/cupertino.dart';

class Constants {
  static const title = "Bar App";
  static const kBlackColor = "0xFF000000";
  static const waitTimeReset = 90;

  //color scheme
  static const waitTimeTextRed = 0xffff3311;
  static const waitTimeTextOrange = 0xfff99500;
  static const waitTimeTextGreen = 0xff2ac300;

  //shared preferences keys
  static const notifiedBarMarkerId = "notifiedBarMarkerId";
  static const notifiedBarLatitude = "notifiedBarLatitude";
  static const notifiedBarLongitude = "notifiedBarLongitude";
  static const notifiedBarInfoWindowTitle = "notifiedBarInfoWindowTitle";
  static const notifiedBarAddress = "notifiedBarAddress";
  static const notifiedBarType = "notifiedBarType";
  static const notificationLastSentTime = "notificationLastSentTime";

  //error codes
  static const waitTimeReportIntervalError = "INTERVAL";
  static const waitTimeReportTimeError = "TIME";
}
