import 'package:Linez/models/location_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../blocs/get_wait_time/wait_time_bloc.dart';
import '../../resources/util/get_distance.dart';
import '../../resources/util/location_util.dart';
import '../bar_page.dart';

class ClickableLocationsList extends StatelessWidget {
  final List<LocationModel> locations;
  final LocationUtil userLocation;

  ClickableLocationsList(
      {Key? key, required this.locations, required this.userLocation})
      : super(key: key);

  //rendered within clickable location widget
  //finds distance between the user and location
  Widget barLocationColumn(LocationModel location, LatLng? userLocation) {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(location.markerId, style: TextStyle(fontSize: 25))),
        if (userLocation?.longitude != null && userLocation?.latitude != null)
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "${calculateDistanceMiles(userLocation?.latitude, userLocation?.longitude, location.position.latitude, location.position.longitude)} miles away"))
        else
          Align(
              alignment: Alignment.centerLeft,
              child: Text(location.address, style: TextStyle(fontSize: 15))),
      ],
    );
  }

  //creates single row with one location
  //when clicked takes the user to a page to report wait times
  Widget clickableLocation(
      LocationModel location, LatLng? userLocation, BuildContext context) {
    print("LOC ${userLocation?.longitude}, ${userLocation?.latitude}");
    context.read<WaitTimeBloc>().add(GetWaitTime(
          address: location.address,
        ));
    return Container(
        //margin: const EdgeInsets.all(15.0),
        //padding: const EdgeInsets.all(3.0),
        width: MediaQuery.of(context).size.width,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
        child: GestureDetector(
          child: Row(
            children: [
              Image.asset("assets/images/beer_can.png", width: 40, height: 40),
              Container(
                width: MediaQuery.of(context).size.width * .70,
                child: barLocationColumn(location, userLocation),
              ),
              FutureBuilder<WaitTimeState>(
                future: getWaitTime(GetWaitTime(
                  address: location.address,
                )),
                builder: (BuildContext context,
                    AsyncSnapshot<WaitTimeState> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.waitTime != null) {
                      if (snapshot.data!.waitTime! >= 0) {
                        return waitTimeDisplay(snapshot.data!.waitTime!,
                            fontSize: 20);
                      }
                    }
                  }
                  return Text("none", style: TextStyle(fontSize: 20));
                },
              )
            ],
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BarPage(location: location)));
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      //GetLocationWidget(),
      Column(
        children: <Widget>[
          for (var location in locations)
            clickableLocation(location, userLocation.getUserLocation(), context)
        ],
      )
    ]));
  }
}
