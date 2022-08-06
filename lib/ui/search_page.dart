import 'package:flutter/material.dart';
import '../models/location_model.dart';
import 'map_test.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  Widget clickableLocation(LocationModel location) {
    return GestureDetector(
      child: Column(
        children: [
          Center(
            child: Text(location.markerId, style: TextStyle(fontSize: 25)),
          ),
          Center(child: Text(location.address, style: TextStyle(fontSize: 15))),
        ],
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    List<LocationModel> locations = getDefaultLocations();
    return Container(
        child: Column(
      children: <Widget>[
        for (var location in locations) clickableLocation(location)
      ],
    ));
  }
}
