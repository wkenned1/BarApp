import 'dart:math';

import 'package:Linez/blocs/phone_auth/phone_auth_bloc.dart';
import 'package:Linez/resources/util/location_util.dart';
import 'package:Linez/ui/coming_soon_page.dart';
import 'package:Linez/ui/map_test.dart';
import 'package:Linez/ui/phone_sign_in_page.dart';
import 'package:Linez/ui/profile_page.dart';
import 'package:Linez/ui/search_page.dart';
import 'package:Linez/ui/user_feedback_page.dart';
import 'package:Linez/ui/widgets/countdown_widget.dart';
import 'package:Linez/ui/widgets/ticket_icon_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:notification_permissions/notification_permissions.dart'
    as NotificationPermissions;
import 'package:url_launcher/url_launcher.dart';

import '../blocs/animation/animation_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../constants.dart';
import '../globals.dart';
import '../main.dart';
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
    title: const Text("Giveaway", style: TextStyle(fontSize: 25),),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(Constants.giveawayExplanation, style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        (Platform.isIOS) ? Text("(${Constants.giveawayDisclaimerIOS})", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .035),) : Text("(${Constants.giveawayDisclaimerAndroid})", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .04),),
        Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0)),
        Center(child: Container(child:
        Row(children: [
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)), onPressed: (){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PhoneAuthPage()),
            );
          }, child: Text("Sign Up", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 5.0, 0)),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)), onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("Not Now", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)),
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
    title: const Text("Giveaway", style: TextStyle(fontSize: 25),),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(Constants.giveawayExplanation, style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        (Platform.isIOS) ? Text("(${Constants.giveawayDisclaimerIOS})", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .035),) : Text("(${Constants.giveawayDisclaimerAndroid})", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .04),),
        Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0)),
        Center(child: Container(child:
        Row(
          children: [
          Column(children: [
          ],),
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
                      fontSize: MediaQuery.of(context).size.width * .05,
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
        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
        Center(child: Container(child:
        Column(children: [
          Text("Countdown to giveaway"),
          Container(
              decoration: new BoxDecoration (
                  color: Colors.green
              ),
              height: MediaQuery.of(context).size.width/10,
              width: MediaQuery.of(context).size.width/2,
              child: new Center(child:
              (!showCountdown) ? Text("00:00:00:00", style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * .05,
                  fontWeight: FontWeight.w900

              ),) :
              CountdownWidget(giveaway: AppInfo.giveawayDate!, fontSize: MediaQuery.of(context).size.width * .05,)
              )
          )
        ],)
        )),
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
  final double ticketOffsetPixels = 10;
  Color iconColor = Colors.white;

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

  void _updateColor() async {
    for(var i = 0; i < 5; i++) {
      setState(() {
        iconColor = Color(Constants.boxBlue);
      });
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        iconColor = Colors.white;
      });
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<PhoneAuthBloc>().add(AuthConfirmLoginEvent());
    NotificationService().initNotification(context);
    double profileIconSize = MediaQuery.of(context).size.width/8;
    return Scaffold(
      backgroundColor: Color(Constants.linezBlue),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
          size: min(MediaQuery.of(context).size.height * .06, MediaQuery.of(context).size.width * .08),//change size on your need//change color on your need
        ),
        toolbarHeight: WidgetsBinding.instance.window.physicalSize.height /35,
        bottom: PreferredSize(
            child: Container(
              color: Colors.white,
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(4.0)),
        backgroundColor: Color(Constants.linezBlue),
        centerTitle: true,
        title: Text("Linez", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'BerkshiresWash', fontSize: MediaQuery.of(context).size.height * .05),),
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
                        InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildTicketSignedInDialog(context));
                          },
                            child: Container(
                              //padding: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width * .025, 0),
                              padding: EdgeInsets.fromLTRB(20, 10, ticketOffsetPixels, 10),
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              //width: 70,
                              //height: 60,
                              child:
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Container(child:
                                Row(
                                  children: [
                                  Image.asset(
                                    'assets/images/ticket_icon.png', // Fixes border issues
                                    width: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06), //profileIconSize/2,
                                    height: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06), //profileIconSize/2,
                                    color: iconColor,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                                  Text("${state.profile.tickets}", style: TextStyle(color: Colors.white, fontSize: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06),)),
                                ],)
                                ),),
                            )
                        /*Container(
                          width: 70,
                            height: 60,
                            child:
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Container(child:
                            Row(children: [
                              Image.asset(
                                'assets/images/ticket_icon.png', // Fixes border issues
                                width: profileIconSize/2,
                                height: profileIconSize/2,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                              Text("${state.profile.tickets}", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)
                            ],),)))*/


                        );
                    }
                    else {
                      return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildTicketDialog(context));
                        },
                        child: Container(
                          //padding: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width * .025, 0),
                          padding: EdgeInsets.fromLTRB(20, 10, ticketOffsetPixels, 10),
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          //width: 70,
                          //height: 60,
                          child:
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Container(child:
                            Row(children: [
                              Image.asset(
                                'assets/images/ticket_icon.png', // Fixes border issues
                                width: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06), //profileIconSize/2,
                                height: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06), //profileIconSize/2,
                                color: iconColor,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                              Text("0", style: TextStyle(color: Colors.white, fontSize: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06),)),
                            ],)
                            ),),
                        )


                      /*Container(
                          width: 70,
                          height: 60,
                          child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, profileIconSize/4, 0),
                        child: Container(child:
                        Row(children: [
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
                      ))*/


                      );
                    }
                  });
                }
                else {
                  return
                    InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildTicketDialog(context));
                        },
                        child: Container(
                        //padding: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width * .025, 0),
                        padding: EdgeInsets.fromLTRB(20, 10, ticketOffsetPixels, 10),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        //width: 70,
                        //height: 60,
                        child:
                        Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(child:
                        Row(children: [
                        Image.asset(
                        'assets/images/ticket_icon.png', // Fixes border issues
                        width: min(MediaQuery.of(context).size.height * .035, MediaQuery.of(context).size.width * .06), //profileIconSize/2,
                        height: min(MediaQuery.of(context).size.height * .035, MediaQuery.of(context).size.width * .06), //profileIconSize/2,
                        color: iconColor,
                        ),
                        Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                        Text("0", style: TextStyle(color: iconColor, fontSize: min(MediaQuery.of(context).size.height * .04, MediaQuery.of(context).size.width * .06),)),
                        MultiBlocListener(
                        listeners: [
                        BlocListener<AnimationBloc, AnimationState>(
                        listener: (context, state) {
                        if(state is TicketAnimating) {
                        print("update");
                        _updateColor();
                        }
                        } )],
                        child: Container(width: 0, height: 0,),)
                        ],)
                        ),),
                        ),);
                }
              }),
        ],
      ),
      drawer: Drawer(
              child:
              ListView(
                children: <Widget>[
                  SizedBox(
                  height: 64.0,
                    child: DrawerHeader(
                        margin: EdgeInsets.all(0.0),
                        padding: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          color: Color(Constants.linezBlue),
                        ),
                        child: Center(child: Text("Linez", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'BerkshiresWash', fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .02, WidgetsBinding.instance.window.physicalSize.width * .04),)))
                    ),
                  ),
                  GestureDetector(
                    child: ListTile(
                      title: Text("Send us feedback", style: TextStyle(fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .01, WidgetsBinding.instance.window.physicalSize.width * .02)),),
                      trailing: Icon(Icons.arrow_forward),
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserFeedbackPage()));
                    },
                  ),
                  GestureDetector(child: ListTile(
                    title: Text("Coming soon", style: TextStyle(fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .01, WidgetsBinding.instance.window.physicalSize.width * .02)),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ComingSoonPage()));
                    },
                  ),
                  GestureDetector(child: ListTile(
                    title: Text("Terms of Service", style: TextStyle(fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .01, WidgetsBinding.instance.window.physicalSize.width * .02)),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                  onTap: () async {
                    const url = 'https://linezapp.com/terms_conditions_app.html';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      throw 'Could not launch $url';
                    }
                  },),
                  GestureDetector(child: ListTile(
                    title: Text("Privacy Policy", style: TextStyle(fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .01, WidgetsBinding.instance.window.physicalSize.width * .02)),),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                    onTap: () async {
                      const url = 'https://linezapp.com/privacy_app.html';
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
                          title: Text("Logout", style: TextStyle(fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .01, WidgetsBinding.instance.window.physicalSize.width * .02)),),
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
                          title: Text("Login with phone", style: TextStyle(fontSize: min(WidgetsBinding.instance.window.physicalSize.height * .01, WidgetsBinding.instance.window.physicalSize.width * .02)),),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
        border:  Border(
          top: BorderSide( //                   <--- right side
          color: Colors.white,
            width: 1.0,
          ),
        )
        ),
        child: BottomNavigationBar(
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
      ));
  }
}
