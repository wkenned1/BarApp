import 'package:bar_app/models/location_model.dart';
import 'package:flutter/material.dart';

class BarPage extends StatelessWidget {
  final LocationModel location;
  const BarPage({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("Wait time for bar: ${location.markerId}"));
  }
}
