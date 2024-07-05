import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/animation/animation_bloc.dart';
import '../../blocs/phone_auth/phone_auth_bloc.dart';

class TicketIconWidget extends StatefulWidget {
  final ticketCount;
  const TicketIconWidget({super.key, this.ticketCount});

  @override
  State<TicketIconWidget> createState() => _TicketIconWidgetState(ticketCount: ticketCount);
}

class _TicketIconWidgetState extends State<TicketIconWidget> {
  double factor = 1;
  bool _large = false;
  final ticketCount;
  final double ticketOffsetPixels = 10;
  bool shake = false;

  _TicketIconWidgetState({this.ticketCount});

  void _updateSize() {
    setState(() {
      factor = _large ? 1 : .75;
      _large = !_large;
    });
  }

  @override
  Widget build(BuildContext context) {
    double profileIconSize = MediaQuery.of(context).size.width/8;
    return
      Container(
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
                    width: profileIconSize/2,
                    height: profileIconSize/2,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),),
                  Text("${ticketCount}", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),),
                  MultiBlocListener(
                    listeners: [
                      BlocListener<AnimationBloc, AnimationState>(
                          listener: (context, state) {
                            if(state is TicketAnimating) {
                              print("update");
                              shake = true;
                            }
                          } )],
                    child: Container(width: 0, height: 0,),)
                ],)
                ),),
      );
  }
}