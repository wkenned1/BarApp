import 'dart:convert';

import 'package:bar_app/ui/bar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../app.dart';
import '../../constants.dart';
import '../../models/location_model.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  static late BuildContext context;

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  void selectNotification(String? payload) async {
    //Handle notification tapped logic here
    print("Notification clicked");
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

  Future<void> initNotification(BuildContext context) async {
    print("initializing notification");
    NotificationService.context = context;
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    print("init1");
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    print("init2");
  }

  Future<void> showNotificationInApp(
      int id, String title, String body, int seconds) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            importance: Importance.max,
            priority: Priority.max,
            icon: 'mipmap/ic_launcher'),
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showNotification(
      int id, String title, String body, int seconds) async {
    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      const NotificationDetails(
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            importance: Importance.max,
            priority: Priority.max,
            icon: 'mipmap/ic_launcher'),
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    prefs.setInt(Constants.notificationLastSentTime, timestamp);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

/*class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          channelId: "wait-time-popup",
          channelName: "Wait Time Popup",
          channelDescription: "Displays when a user is near a bar",
          importance: Importance.high,
          priority: Priority.high);

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: (
        int id,
        String? title,
        String? body,
        String? payload,
      ) async {},
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void selectNotification(String? payload) async {
    //Handle notification tapped logic here
  }

  void onDidReceiveLocalNotification(String? s1, String? s2, String? s3) {}
}*/
