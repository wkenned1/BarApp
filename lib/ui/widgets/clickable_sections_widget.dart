import 'package:flutter/material.dart';
import 'dart:math' as math;

class ClickableSectionsWidget extends StatefulWidget {
  final String sectionTitle;
  const ClickableSectionsWidget({Key? key, required this.sectionTitle})
      : super(key: key);

  @override
  _ClickableSectionsWidgetState createState() =>
      _ClickableSectionsWidgetState(sectionTitle);
}

class _ClickableSectionsWidgetState extends State<ClickableSectionsWidget> {
  final String sectionTitle;
  bool sectionOpen = false;
  double turns = 0.0;

  _ClickableSectionsWidgetState(this.sectionTitle);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Align(
                child: Transform.rotate(
                  angle: sectionOpen ? -math.pi / 2 : 0,
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
    );
  }
}

class ClickableSectionsStatelessWidget extends StatelessWidget {
  final String sectionTitle;
  final bool sectionOpen;

  ClickableSectionsStatelessWidget(
      {Key? key, required this.sectionTitle, required this.sectionOpen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.grey),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 4, 5, 4),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .85,
              child: Align(
                child: Text(
                  sectionTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
            Align(
              child: Transform.rotate(
                angle: sectionOpen ? -math.pi / 2 : 0,
                child: Image.asset("assets/images/arrow_icon.png",
                    width: 30, height: 30),
              ),
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
    );
  }
}
