import 'dart:ffi';

import 'package:bar_app/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../blocs/wait_time_report/wait_time_report_bloc.dart';

class BarPage extends StatelessWidget {
  final LocationModel location;
  const BarPage({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int waitTime = -1;
    final myController = TextEditingController();
    context.read<WaitTimeBloc>().add(GetWaitTime(
          address: location.address,
        ));
    /*return BlocListener<WaitTimeBloc, WaitTimeState>(
      listener: (context, state) {
        if (state.waitTime != null) {
          print("wait time from bloc: ${state.waitTime!}");
          waitTime = state.waitTime!;
        }
      },
      child: */
    return Scaffold(
        body: Column(children: [
      BlocBuilder<WaitTimeBloc, WaitTimeState>(builder: (context, state) {
        final time = state.waitTime ?? -1;
        return Text("Current Wait Time: ${time >= 0 ? time : "none"}");
        // return widget here based on BlocA's state
      }),
      ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Back")),
      TextFormField(
        keyboardType: TextInputType.number,
        controller: myController,
      ),
      ElevatedButton(
          onPressed: () {
            context.read<WaitTimeReportBloc>().add(WaitTimeReportEvent(
                address: location.address,
                waitTime: int.parse(myController.text)));
          },
          child: Text("Submit"))
    ]));
    //);
  }
}
