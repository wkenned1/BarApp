import 'dart:async';

import 'package:Linez/resources/repositories/authentication_repository_impl.dart';
import 'package:Linez/resources/repositories/database_repository_impl.dart';
import 'package:Linez/resources/services/database_service.dart';
import 'package:Linez/resources/services/notification_service.dart';
import 'package:Linez/resources/util/get_distance.dart';
import 'package:Linez/ui/sign_up_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/database/database_bloc.dart';
import 'blocs/form/form_bloc.dart';
import 'blocs/get_wait_time/wait_time_bloc.dart';
import 'blocs/wait_time_report/wait_time_report_bloc.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'app_bloc_observer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'globals.dart';
import 'models/location_model.dart';
import 'package:geolocator/geolocator.dart' as Geo;

late final NotificationAppLaunchDetails? appLaunchDetails;

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final locations = await DatabaseService().getLocations();
  Locations.defaultBars = [];
  Locations.defaultClubs = [];
  for (var loc in locations) {
    if (loc.type == "bar") {
      Locations.defaultBars.add(loc);
    } else if (loc.type == "night_club") {
      Locations.defaultClubs.add(loc);
    }
  }
  tz.initializeTimeZones();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  appLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  NotificationService().requestIOSPermissions(flutterLocalNotificationsPlugin);

  //background process for sending notifications while the app is open
  Timer timerObj;
  timerObj = Timer.periodic(Duration(seconds: 15), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    int? ts = prefs.getInt(Constants.notificationLastSentTime);
    bool sendNotification = false;
    print("TIMESTAMP2: ${prefs.getInt(Constants.notificationLastSentTime)}");
    if (ts != null) {
      final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts);
      print("time 1");
      print("DT: ${prev_ts.toString()}");
      if (prev_ts.difference(DateTime.now()).inHours > 7) {
        print("time 2");
        sendNotification = true;
      }
    } else {
      sendNotification = true;
    }
    print("working1");

    if (sendNotification) {
      //check if the current time is within the allowed range for sending notifications
      int hour = DateTime.now().hour;
      int weekday = DateTime.now().weekday;
      if ((hour >= 20 &&
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
        print("working12");
        LatLng? userLocation = await _getUserPosition();
        print("working2");
        if (userLocation != null) {
          print("working3");
          final locations = new List.from(Locations.defaultBars)
            ..addAll(Locations.defaultClubs);
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
            print("working4");
            if (shortestDistance <= 50) {
              print("working5");
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
              print("notification1");
              NotificationService().showNotification(
                  1,
                  "Near ${shortestLocation.markerId}? What's the wait?",
                  "Click to report wait the time",
                  1);
              print("notification2");
            }
          }
        } else {
        }
      } else {}
    }
  });

  BlocOverrides.runZoned(
    () => runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthenticationBloc(AuthenticationRepositoryImpl())
                ..add(AuthenticationStarted()),
        ),
        BlocProvider(
          create: (context) => FormBloc(
              AuthenticationRepositoryImpl(), DatabaseRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => DatabaseBloc(DatabaseRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => WaitTimeBloc(DatabaseRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => WaitTimeReportBloc(DatabaseRepositoryImpl()),
        )
      ],
      child: MyApp(),
    )),
    blocObserver: AppBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('LoginPage'),
            child: SignUpView(),
          )
        ],
        onPopPage: (route, result) => route.didPop(result),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme
                  .of(context)
                  .textTheme
                  .headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
