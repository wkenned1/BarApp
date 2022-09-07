import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountdownWidget extends StatefulWidget {
  final DateTime giveaway;
  CountdownWidget({Key? key, required this.giveaway}) : super(key: key);
  @override
  _CountdownWidgetState createState() => _CountdownWidgetState(giveaway: giveaway);
}

class _CountdownWidgetState extends State<CountdownWidget> {
  final DateTime giveaway;
  late Timer timer;

  _CountdownWidgetState({Key? key, required this.giveaway});

  @override
  void initState() {
    print("countdown");
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (this.mounted) {
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime current = DateTime.now().toUtc();
    int diffDays = giveaway.difference(current).inDays;
    int diffHours = giveaway.difference(current).inHours - (diffDays * 24);
    int diffMins = giveaway.difference(current).inMinutes - (diffHours * 60) - (diffDays * 24 * 60);
    int diffSecs = giveaway.difference(current).inSeconds - (diffMins * 60) - (diffHours * 60 * 60) - (diffDays * 24 * 60 * 60);
    // TODO: implement build
    return (DateTime.now().toUtc().isAfter(giveaway)) ? Text("00:00:00:00", style: TextStyle(
        color: Colors.white,
        fontSize: MediaQuery.of(context).size.width * .04,
        fontWeight: FontWeight.w900

    ),) :
    Text("${(diffDays > 9) ? diffDays : "0${diffDays}"}:"
        "${(diffHours > 9) ? diffHours : "0${diffHours}"}:"
        "${(diffMins > 9) ? diffMins : "0${diffMins}"}:"
        "${(diffSecs > 9) ? diffSecs : "0${diffSecs}"}", style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900

    ),)
    ;
  }
}