import 'dart:ffi';

import 'package:bar_app/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/wait_time/wait_time_bloc.dart';

class BarPage extends StatelessWidget {
  final LocationModel location;
  const BarPage({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return Scaffold(
        body: Column(children: [
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
            context.read<WaitTimeBloc>().add(ReportWaitTime(
                address: location.address,
                waitTime: int.parse(myController.text)));
          },
          child: Text("Submit"))
    ]));
  }
}
