import 'package:Linez/resources/util/location_util.dart';
import 'package:Linez/ui/coming_soon_page.dart';
import 'package:Linez/ui/map_test.dart';
import 'package:Linez/ui/phone_sign_in_page.dart';
import 'package:Linez/ui/profile_page.dart';
import 'package:Linez/ui/search_page.dart';
import 'package:Linez/ui/user_feedback_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    double profileIconSize = MediaQuery.of(context).size.width/10;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold),),
        //automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, profileIconSize/3, 0),
            child: GestureDetector(
              onTap: () {
                FirebaseAuth auth = FirebaseAuth.instance;
                var user = auth.currentUser;
                if(user != null) {
                  if(user!.uid != null){
                    print(user!.uid);
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ProfilePage()));
                  }
                  else {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => PhoneAuthPage()));
                  }
                }
                else {
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => PhoneAuthPage()));
                }
              }, // Image tapped
              child: Image.asset(
                'assets/images/profile_icon.png', // Fixes border issues
                width: profileIconSize,
                height: profileIconSize,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  GestureDetector(
                    child: ListTile(
                      title: Text("Send us feedback", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                      trailing: Icon(Icons.arrow_forward),
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserFeedbackPage()));
                    },
                  ),
                  GestureDetector(child: ListTile(
                    title: Text("Coming soon", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ComingSoonPage()));
                    },
                  ),
                  GestureDetector(child: ListTile(
                    title: Text("Logout", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                    onTap: (){

                    },
                  ),
                ],
              ),
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
