import 'package:Linez/resources/util/location_util.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:math' as math;

import '../../constants.dart';
import '../../models/location_model.dart';
import 'clickable_location_widget.dart';

class ClickableSectionsWidget extends StatefulWidget {
  final String sectionTitle;
  final ClickableLocationsList body;
  const ClickableSectionsWidget(
      {Key? key, required this.sectionTitle, required this.body})
      : super(key: key);

  @override
  _ClickableSectionsWidgetState createState() =>
      _ClickableSectionsWidgetState(sectionTitle, body);
}

class _ClickableSectionsWidgetState extends State<ClickableSectionsWidget> {
  final String sectionTitle;
  bool sectionOpen = true;
  double turns = 0.0;
  final ClickableLocationsList body;

  _ClickableSectionsWidgetState(this.sectionTitle, this.body);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: GestureDetector(
          child: Container(
          //width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/15,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color(Constants.boxBlue)),
          child: Padding(
              padding: EdgeInsets.fromLTRB(10, 4, 5, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .6,
                    child: Align(
                      child: Text(
                        sectionTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .3 - 20,
                    child: Align(
                    child: Transform.rotate(
                      angle: !sectionOpen ? -math.pi / 2 : 0,
                      child: Image.asset("assets/images/arrow_icon.png",
                          width: 25, height: 25, color: Colors.white,),
                    ),
                    alignment: Alignment.centerRight,
                  ),)
                ],
              ),
            ),
          ),
          onTap: () {
            setState(() {
              if (sectionOpen) {
                sectionOpen = false;
                turns = 0;
              } else {
                sectionOpen = true;
                turns = 90;
              }
            });
          },
        )),
        Visibility(maintainState: true, visible: sectionOpen, child: body)
      ],
    );
  }
}
