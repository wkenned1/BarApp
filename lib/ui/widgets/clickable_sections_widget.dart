import 'package:Linez/resources/util/location_util.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:math' as math;

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
  bool sectionOpen = false;
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
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.grey),
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 4, 5, 4),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .85,
                    child: Align(
                      child: Text(
                        sectionTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Align(
                    child: Transform.rotate(
                      angle: !sectionOpen ? -math.pi / 2 : 0,
                      child: Image.asset("assets/images/arrow_icon.png",
                          width: 30, height: 30),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ],
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
          ),
        ),
        Visibility(maintainState: true, visible: sectionOpen, child: body)
      ],
    );
  }
}
