import 'dart:ffi';

import 'package:bar_app/constants.dart';
import 'package:bar_app/models/location_model.dart';
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
        body: Column(children: [
          Text(
            "${location.markerId}",
            style: TextStyle(fontSize: 30),
          ),
          BlocBuilder<WaitTimeBloc, WaitTimeState>(builder: (context, state) {
            final time = state.waitTime ?? -1;

            return time >= 0
                ? waitTimeDisplay(time)
                : Text("No wait time available");
            // return widget here based on BlocA's state
          }),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Back")),
          Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    index = 0;
                    setState(() => pressAttention = 0);
                  },
                  child: Text("0 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 0 ? Colors.grey : Colors.blue,
                  )),
              ElevatedButton(
                  onPressed: () {
                    index = 1;
                    setState(() => pressAttention = 1);
                  },
                  child: Text("5 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 1 ? Colors.grey : Colors.blue,
                  )),
              ElevatedButton(
                  onPressed: () {
                    index = 2;
                    setState(() => pressAttention = 2);
                  },
                  child: Text("10 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 2 ? Colors.grey : Colors.blue,
                  )),
              ElevatedButton(
                  onPressed: () {
                    index = 3;
                    setState(() => pressAttention = 3);
                  },
                  child: Text("20 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 3 ? Colors.grey : Colors.blue,
                  )),
              ElevatedButton(
                  onPressed: () {
                    index = 4;
                    setState(() => pressAttention = 4);
                  },
                  child: Text("30 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 4 ? Colors.grey : Colors.blue,
                  )),
              ElevatedButton(
                  onPressed: () {
                    index = 5;
                    setState(() => pressAttention = 5);
                  },
                  child: Text("45 min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 5 ? Colors.grey : Colors.blue,
                  )),
              ElevatedButton(
                  onPressed: () {
                    index = 6;
                    setState(() => pressAttention = 6);
                  },
                  child: Text("60+ min"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        pressAttention != 6 ? Colors.grey : Colors.blue,
                  )),
            ],
          ),
          ElevatedButton(
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
                }
                setState(() => pressAttention = -1);
                if (submission >= 0) {
                  context.read<WaitTimeReportBloc>().add(WaitTimeReportEvent(
                      address: location.address,
                      waitTime: /*int.parse(myController.text)*/ submission));
                }
              },
              child: Text("Submit"))
        ]));
  }
}
