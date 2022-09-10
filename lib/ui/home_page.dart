import 'package:Linez/blocs/phone_auth/phone_auth_bloc.dart';
import 'package:Linez/resources/util/location_util.dart';
import 'package:Linez/ui/coming_soon_page.dart';
import 'package:Linez/ui/map_test.dart';
import 'package:Linez/ui/phone_sign_in_page.dart';
import 'package:Linez/ui/profile_page.dart';
import 'package:Linez/ui/search_page.dart';
import 'package:Linez/ui/user_feedback_page.dart';
import 'package:Linez/ui/widgets/countdown_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:notification_permissions/notification_permissions.dart'
    as NotificationPermissions;
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';

import '../blocs/profile/profile_bloc.dart';
import '../constants.dart';
import '../globals.dart';
import '../resources/services/notification_service.dart';
import '../resources/util/get_location.dart';
import 'logout_page.dart';

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

//show popup when ticket icon is clicked
Widget _buildTicketDialog(BuildContext context) {
  return new AlertDialog(
    title: const Text("Giveaway"),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Everytime you submit a line estimate you will get 1 ticket for a chance to win a \$100 dollar gift card."),
        Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0)),
        Center(child: Container(child:
        Row(children: [
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)), onPressed: (){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PhoneAuthPage()),
            );
          }, child: Text("Sign Up")),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 5.0, 0)),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)), onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("No")),
        ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        ),),
      ],
    ),
  );
}

//show popup when ticket icon is clicked
Widget _buildTicketSignedInDialog(BuildContext context) {
  bool showCountdown = false;
  if(AppInfo.giveawayDate != null) {
    if(AppInfo.giveawayDate!.isAfter(DateTime.now().toUtc())) {
      showCountdown = true;
    }
  }
  return new AlertDialog(
    title: const Text("Giveaway"),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Everytime you submit a line estimate you will get 1 ticket for a chance to win a \$100 dollar gift card."),
        Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0)),
        Center(child: Container(child:
        Row(
          children: [
          Column(children: [
            Text("Time left"),
            Container(
                decoration: new BoxDecoration (
                    color: Colors.green
                ),
              height: MediaQuery.of(context).size.width/13,
              width: MediaQuery.of(context).size.width/2.5,
              child: new Center(child:
              (!showCountdown) ? Text("00:00:00:00", style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * .04,
                    fontWeight: FontWeight.w900

              ),) :
                CountdownWidget(giveaway: AppInfo.giveawayDate!)
              )
            )
          ],),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
          Column(children: [
            Text("Your tickets"),
            Container(
              height: MediaQuery.of(context).size.width/13,
              width: MediaQuery.of(context).size.width/7,
              child: new Center(child:
              Text (
                  "#${UserData.userTickets}",
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * .04,
                      fontWeight: FontWeight.w900
                  )
              ),),
              decoration: new BoxDecoration (
                  color: Color(Constants.linezBlue)
              ),
            )
          ],),
        ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        ),),
      ],
    ),
  );
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
              color: Colors.white,
              width: (bottomSelectedIndex == 0) ? 35 : 25,
              height: (bottomSelectedIndex == 0) ? 35 : 25),
          label: "Search"),
      BottomNavigationBarItem(
        icon: Image.asset("assets/images/map_icon.png",
            color: Colors.white,
            width: (bottomSelectedIndex == 1) ? 35 : 25,
            height: (bottomSelectedIndex == 1) ? 35 : 25),
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
    context.read<PhoneAuthBloc>().add(AuthConfirmLoginEvent());
    NotificationService().initNotification(context);
    double profileIconSize = MediaQuery.of(context).size.width/10;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(Constants.linezBlue),
        centerTitle: true,
        title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold),),
        //automaticallyImplyLeading: false,
        actions: <Widget>[
          BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
              builder: (context, state) {
                if(state is AuthLoginConfirmed){
                  context.read<ProfileBloc>().add(GetProfileEvent());
                  return
                  BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if(state is ProfileUpdatedState){
                      return
                        GestureDetector(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildTicketSignedInDialog(context));
                          },
                            child:
                        Container(child:
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, profileIconSize/4, 0),
                            child: Container(child: Row(children: [
                              Image.asset(
                                'assets/images/ticket_icon.png', // Fixes border issues
                                width: profileIconSize/2,
                                height: profileIconSize/2,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                              Text("${state.profile.tickets}", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)
                            ],),))));
                    }
                    else {
                      return GestureDetector(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildTicketDialog(context));
                        },
                        child:
                      Container(child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, profileIconSize/4, 0),
                        child: Container(child: Row(children: [
                          Image.asset(
                            'assets/images/ticket_icon.png', // Fixes border issues
                            width: profileIconSize/2,
                            height: profileIconSize/2,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                          Text("0", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)
                        ],),),
                      ))
                      );
                    }
                  });
                }
                else {
                  return GestureDetector(child:
                      Container(child:
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, profileIconSize/4, 0),
                        child: Container(child: Row(children: [
                          Image.asset(
                            'assets/images/ticket_icon.png', // Fixes border issues
                            width: profileIconSize/2,
                            height: profileIconSize/2,
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                          Text("0", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)
                        ],),),
                      ),),
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildTicketDialog(context));
                    },
                  );
                }
              }),
        ],
      ),
      drawer: Drawer(
              child:
              ListView(
                children: <Widget>[
                  const SizedBox(
                  height: 64.0,
                    child: DrawerHeader(
                        margin: EdgeInsets.all(0.0),
                        padding: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          color: Color(Constants.linezBlue),
                        ),
                        child: Center(child: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),))
                    ),
                  ),
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
                    title: Text("Terms of Service", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                  onTap: () async {
                    const url = 'https://linezapp.com/terms_conditions.html';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      throw 'Could not launch $url';
                    }
                  },),
                  GestureDetector(child: ListTile(
                    title: Text("Privacy Policy", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                    onTap: () async {
                      const url = 'https://linezapp.com/privacy.html';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        throw 'Could not launch $url';
                      }
                    },),
                  BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                      builder: (context, state) {
                      if(state is AuthLoginConfirmed){
                        return GestureDetector(child: ListTile(
                          title: Text("Logout", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LogoutPage()));
                          },
                        );
                      }
                      else {
                        return GestureDetector(child: ListTile(
                          title: Text("Login with phone", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PhoneAuthPage()));
                          },
                        );
                      }
                    }),
                ],
              ),
        ),
      body: buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Color(Constants.linezBlue),
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          bottomTapped(index);
        },
        selectedLabelStyle: TextStyle(color: Colors.white),
        items: buildBottomNavBarItems(),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
      ),
    );
  }
}
