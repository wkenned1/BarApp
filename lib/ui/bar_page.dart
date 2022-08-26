import 'dart:ffi';

import 'package:Linez/constants.dart';
import 'package:Linez/models/location_model.dart';
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

  Widget _buildPopupDialog(int hour, int day, BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    int waitTime = -1;
    context.read<WaitTimeBloc>().add(GetWaitTime(
          address: location.address,
        ));
    return Scaffold(
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          title: Text("Linez"),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
            child: Column(children: [
          Text(
            "${location.markerId}",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
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
                    int hour = DateTime.now().hour;
                    int weekday = DateTime.now().weekday;
                    if ((hour > 20 &&
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
                                waitTime: submission));
                      }
                      Navigator.of(context).pop();
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildPopupDialog(hour, weekday, context),
                      );
                    }
                  },
                  child: Text("Submit", style: TextStyle(fontSize: 30))))
        ])));
  }
}
