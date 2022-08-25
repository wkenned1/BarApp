import 'package:Linez/resources/util/location_util.dart';
import 'package:Linez/ui/map_test.dart';
import 'package:Linez/ui/search_page.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:notification_permissions/notification_permissions.dart'
    as NotificationPermissions;
import 'package:workmanager/workmanager.dart';

import '../resources/services/notification_service.dart';
import '../resources/util/get_location.dart';

class GetLocationWidget extends StatefulWidget {
  const GetLocationWidget({Key? key}) : super(key: key);

  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocationWidget> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Future<void> _getUserLocation() async {
    print("FINDING LOCATION");
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
    print(
        "RESULT: ${util.getUserLocation()?.latitude}, ${util.getUserLocation()?.longitude}");
    setState(() {
      _userLocation = _locationData;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getUserLocation();
    return Scaffold();
  }
}

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int bottomSelectedIndex = 0;

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          icon: Image.asset("assets/images/martini_glass_icon.png",
              color: (bottomSelectedIndex == 0) ? Colors.blue : Colors.black,
              width: 24,
              height: 24),
          label: "Search"),
      BottomNavigationBarItem(
        icon: Image.asset("assets/images/map_icon.png",
            color: (bottomSelectedIndex == 1) ? Colors.blue : Colors.black,
            width: 24,
            height: 24),
        label: "Map",
      ),
    ];
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        SearchPage(),
        MapSample(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    NotificationService().initNotification(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Linez"),
        automaticallyImplyLeading: false,
      ),
      body: buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          bottomTapped(index);
        },
        items: buildBottomNavBarItems(),
      ),
    );
  }
}
