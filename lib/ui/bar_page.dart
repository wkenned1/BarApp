import 'dart:ffi';

import 'package:Linez/constants.dart';
import 'package:Linez/globals.dart';
import 'package:Linez/models/location_model.dart';
import 'package:Linez/resources/services/database_service.dart';
import 'package:Linez/ui/widgets/camera_widget.dart';
import 'package:camera/camera.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:location/location.dart';

import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/wait_time_report/wait_time_report_bloc.dart';

Widget waitTimeDisplay(int time, {double fontSize = 15}) {
  return Text(
    "${time} min",
    style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Color((time <= 10)
            ? Constants.waitTimeTextGreen
            : (time > 10 && time <= 30)
                ? Constants.waitTimeTextOrange
                : Constants.waitTimeTextRed)),
  );
}

Widget waitTimeDisplayAdjustable(int time, double width) {
  return Text(
    "${time} min",
    style: TextStyle(
      fontWeight: FontWeight.bold,
        fontSize: width*.05,
        color: Color((time <= 10)
            ? Constants.waitTimeTextGreen
            : (time > 10 && time <= 30)
            ? Constants.waitTimeTextOrange
            : Constants.waitTimeTextRed)),
  );
}

class BarPage extends StatefulWidget {
  final LocationModel location;
  BarPage({Key? key, required this.location}) : super(key: key);
  @override
  _BarPageState createState() => _BarPageState(location: this.location);
}

class _BarPageState extends State<BarPage> {
  final LocationModel location;
  final myController = TextEditingController();
  int index = -1;
  _BarPageState({Key? key, required this.location});

  int pressAttention = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAnalytics.instance
        .setCurrentScreen(
        screenName: 'WaitTimeReportPage'
    );
    FirebaseAnalytics.instance.logEvent(
      name: 'pageView',
      parameters: {
        'page': 'WaitTimeReportPage',
      },
    );
  }

  Widget _buildTimeErrorDialog(int hour, int day, BuildContext context) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text((day < 4)
              ? "It's a weekday bozo, there's no line out here."
              : (hour > 2 && hour < 6)
                  ? "It's too late to enter a line time dummy. Submit your line estimate between 8:00pm and 2:00am."
                  : "It's too early to enter a line time dummy. Submit your line estimate between 8:00pm and 2:00am."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
          backgroundColor: Color(Constants.linezBlue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildIntervalErrorDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("You can only report the same bar every hour."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.linezBlue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLocationErrorDialog(bool locEnabled, BuildContext context, {bool locImprecise = false}) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (locImprecise) ? Text("You must have precise location tracking enabled") :
          Text(locEnabled ? "You have to be close to the bar to report a wait time." : "You must enable location tracking before reporting a wait time."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.linezBlue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  void goToCamera(BuildContext context, LocationModel location) async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TakePictureScreen(camera: firstCamera, id: location.infoWindowTitle, location: location)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double buttonHeight = MediaQuery.of(context).size.height * .07;
    double buttonWidth = MediaQuery.of(context).size.width * .4;
    double buttonTextSize = MediaQuery.of(context).size.width*.06;
    int waitTime = -1;
    context.read<WaitTimeBloc>().add(GetWaitTime(
          id: location.infoWindowTitle,
        ));
    return LoaderOverlay( child: Scaffold(
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          backgroundColor: Color(Constants.linezBlue),
          centerTitle: true,
          title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'BerkshiresWash', fontSize: MediaQuery.of(context).size.width * .07),),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(children: [
          Center(
              child: SingleChildScrollView(
                  child: Column(children: [
                    Text(
                      "${location.markerId}",
                      style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1, fontWeight: FontWeight.bold),
                    ),
                    BlocBuilder<WaitTimeBloc, WaitTimeState>(builder: (context, state) {
                      final time = state.waitTime ?? -1;

                      return time >= 0
                          ? waitTimeDisplay(time, fontSize: MediaQuery.of(context).size.width*.08)
                          : Text("No wait time available",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*.08));
                      // return widget here based on BlocA's state
                    }),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                    Column(
                      children: [
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 0;
                                  setState(() => pressAttention = 0);
                                },
                                child: Text("0 min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 0 ? Color(Constants.boxBlue) : Color(Constants.linezBlue),
                                ))),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 1;
                                  setState(() => pressAttention = 1);
                                },
                                child: Text("5 min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 1 ? Color(Constants.boxBlue) : Color(Constants.linezBlue),
                                ))),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 2;
                                  setState(() => pressAttention = 2);
                                },
                                child: Text("10 min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 2 ? Color(Constants.boxBlue) : Color(Constants.linezBlue),
                                ))),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 3;
                                  setState(() => pressAttention = 3);
                                },
                                child: Text("20 min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 3 ? Color(Constants.boxBlue) : Color(Constants.linezBlue),
                                ))),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 4;
                                  setState(() => pressAttention = 4);
                                },
                                child: Text("30 min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 4 ? Color(Constants.boxBlue) : Color(Constants.linezBlue),
                                ))),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 5;
                                  setState(() => pressAttention = 5);
                                },
                                child: Text("45 min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 5 ? Color(Constants.boxBlue) : Color(Constants.linezBlue),
                                ))),
                        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                        Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: ElevatedButton(
                                onPressed: () {
                                  index = 6;
                                  setState(() => pressAttention = 6);
                                },
                                child: Text("60+ min", style: TextStyle(fontSize: buttonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pressAttention != 6 ? Color(Constants.boxBlue): Color(Constants.linezBlue),
                                ))),
                      ],
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                    Container(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton(
                            onPressed: () {
                              int submission = -1;
                              switch (index) {
                                case 0:
                                  submission = 0;
                                  break;
                                case 1:
                                  submission = 5;
                                  break;
                                case 2:
                                  submission = 10;
                                  break;
                                case 3:
                                  submission = 20;
                                  break;
                                case 4:
                                  submission = 30;
                                  break;
                                case 5:
                                  submission = 45;
                                  break;
                                case 6:
                                  submission = 60;
                                  break;
                                default:
                                  break;
                              }
                              //setState(() => pressAttention = -1);
                              if (submission >= 0) {
                                context.read<WaitTimeReportBloc>().add(
                                    WaitTimeReportEvent(
                                        id: location.infoWindowTitle,
                                        location: location.position,
                                        waitTime: submission));
                              }
                              //Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(Constants.submitButtonBlue),
                            ),
                            child: Text("Submit", style: TextStyle(fontSize: 30)))),
                    MultiBlocListener(
                      listeners: [
                        BlocListener<WaitTimeReportBloc, WaitTimeReportState>(
                          listener: (context, state) {
                            if (state.errorMessage == null) {
                              if(state.submitSuccessful){
                                //TODO test then statement
                                DatabaseService().incrementTickets().then((value) => context.read<ProfileBloc>().add(GetProfileEvent()));
                                Navigator.of(context).pop();
                              }
                              else if(state.loading) {
                                context.loaderOverlay.show();
                              }
                            }
                            else {
                              context.loaderOverlay.hide();
                              if(state.errorMessage == Constants.waitTimeReportIntervalError){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildIntervalErrorDialog(context));

                              }
                              else if (state.errorMessage == Constants.waitTimeReportTimeError) {
                                int hour = DateTime.now().hour;
                                int weekday = DateTime.now().weekday;
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildTimeErrorDialog(hour, weekday, context));
                              }
                              else if (state.errorMessage == Constants.waitTimeReportLocationError) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildLocationErrorDialog(true, context));
                              }
                              else if (state.errorMessage == Constants.waitTimeReportNoLocationError) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildLocationErrorDialog(false, context));
                              }
                              else if(state.errorMessage == Constants.waitTimeImpreciseLocationError) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildLocationErrorDialog(false, context, locImprecise: true));
                              }
                            }
                          },
                        ),
                      ],
                      child: Container(),
                    )],
                  )
              )
          ),
          Positioned(
              bottom: -MediaQuery.of(context).size.width*.03,
              right: -MediaQuery.of(context).size.width*.03,
              child:
              Container(
                height: MediaQuery.of(context).size.width*.3,
                width: MediaQuery.of(context).size.width*.3,
                child: FittedBox(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Color(Constants.submitButtonBlue)
                      ),
                      child: Icon(Icons.camera_alt),
                      onPressed: () {
                        print("clicked");
                        goToCamera(context, location);
                      }),
                ),
              )),
        ],),
      ));
  }
}
