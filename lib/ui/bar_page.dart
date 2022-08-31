import 'dart:ffi';

import 'package:Linez/constants.dart';
import 'package:Linez/globals.dart';
import 'package:Linez/models/location_model.dart';
import 'package:Linez/resources/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../blocs/wait_time_report/wait_time_report_bloc.dart';

Widget waitTimeDisplay(int time, {double fontSize = 15}) {
  return Text(
    "${time} min",
    style: TextStyle(
        fontSize: fontSize,
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
          Text("You can only report the same bar every two hours."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLocationErrorDialog(bool locEnabled, BuildContext context) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(locEnabled ? "You have to be close to the bar to report a wait time." : "You must enable location tracking before reporting a wait time."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int waitTime = -1;
    context.read<WaitTimeBloc>().add(GetWaitTime(
          address: location.address,
        ));
    return Scaffold(
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold),),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: Column(children: [
                  Text(
                    "${location.markerId}",
                    style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1, fontWeight: FontWeight.bold),
                  ),
                  BlocBuilder<WaitTimeBloc, WaitTimeState>(builder: (context, state) {
                    final time = state.waitTime ?? -1;

                    return time >= 0
                        ? waitTimeDisplay(time, fontSize: 30)
                        : Text("No wait time available",
                        style: TextStyle(fontSize: 30));
                    // return widget here based on BlocA's state
                  }),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  Column(
                    children: [
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 0;
                                setState(() => pressAttention = 0);
                              },
                              child: Text("0 min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 0 ? Colors.grey : Colors.blue,
                              ))),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 1;
                                setState(() => pressAttention = 1);
                              },
                              child: Text("5 min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 1 ? Colors.grey : Colors.blue,
                              ))),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 2;
                                setState(() => pressAttention = 2);
                              },
                              child: Text("10 min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 2 ? Colors.grey : Colors.blue,
                              ))),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 3;
                                setState(() => pressAttention = 3);
                              },
                              child: Text("20 min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 3 ? Colors.grey : Colors.blue,
                              ))),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 4;
                                setState(() => pressAttention = 4);
                              },
                              child: Text("30 min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 4 ? Colors.grey : Colors.blue,
                              ))),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 5;
                                setState(() => pressAttention = 5);
                              },
                              child: Text("45 min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 5 ? Colors.grey : Colors.blue,
                              ))),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                      Container(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: () {
                                index = 6;
                                setState(() => pressAttention = 6);
                              },
                              child: Text("60+ min", style: TextStyle(fontSize: 30)),
                              style: ElevatedButton.styleFrom(
                                primary:
                                pressAttention != 6 ? Colors.grey : Colors.blue,
                              ))),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
                  Container(
                      width: 200,
                      height: 50,
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
                                        address: location.address,
                                        location: location.position,
                                        waitTime: submission));
                              }
                              //Navigator.of(context).pop();
                            },
                          child: Text("Submit", style: TextStyle(fontSize: 30)))),
                MultiBlocListener(
                    listeners: [
                      BlocListener<WaitTimeReportBloc, WaitTimeReportState>(
                    listener: (context, state) {
                      if (state.errorMessage == null) {
                        if(state.submitSuccessful){
                          UserData.userTickets += 1;
                          DatabaseService().incrementTickets();
                          Navigator.of(context).pop();
                        }
                      }
                      else {
                        print("STATE ERROR: ${state.errorMessage}");
                        print("STATE Opt1: ${Constants.waitTimeReportIntervalError}");
                        print("STATE Opt2: ${Constants.waitTimeReportTimeError}");
                        print(state.errorMessage == Constants.waitTimeReportIntervalError);
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
                      }
                    },
                  ),
                ],
                child: Container(),
                )],
                )
            )
            ));
  }
}
