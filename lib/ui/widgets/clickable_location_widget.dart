import 'package:Linez/globals.dart';
import 'package:Linez/models/location_model.dart';
import 'package:Linez/resources/util/get_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../blocs/get_wait_time/wait_time_bloc.dart';
import '../../blocs/user_location/user_location_bloc.dart';
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
        if (userLocation != null)
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "${calculateDistanceMiles(userLocation!.latitude, userLocation!.longitude, location.position.latitude, location.position.longitude)} miles away"))
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
    context.read<WaitTimeBloc>().add(GetWaitTime(
      address: location.address,
    ));
    return GestureDetector(child: Container(
      //margin: const EdgeInsets.all(15.0),
      //padding: const EdgeInsets.all(3.0),
      width: MediaQuery.of(context).size.width,
      decoration:
      BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
      child: Row(
        children: [
          if(location.type == "bar")
            Image.asset("assets/images/bar_icon.png", width: 40, height: 40)
          else
            Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0), child: Image.asset("assets/images/club_icon.png", width: 30, height: 30),),
          Container(
              width: MediaQuery.of(context).size.width * .70,
              child: barLocationColumn(location, userLocation),
          ),
          /*BlocBuilder<UserLocationBloc, UserLocationState>(
              builder: (context, state) {
                if (state is UserLocationUpdate) {
                  return Container(
                    width: MediaQuery.of(context).size.width * .70,
                    child: barLocationColumn(location, state.location),
                  );
                }
                else {
                    return Container(
                      width: MediaQuery.of(context).size.width * .70,
                      child: barLocationColumn(location, null),
                    );
                }
              }),*/
          FutureBuilder<WaitTimeState>(
            future: getWaitTime(GetWaitTime(
              address: location.address,
            )),
            builder: (BuildContext context,
                AsyncSnapshot<WaitTimeState> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data?.waitTime != null) {
                  if (snapshot.data!.waitTime! >= 0) {
                    return waitTimeDisplayAdjustable(snapshot.data!.waitTime!, MediaQuery.of(context).size.width);//waitTimeDisplay(snapshot.data!.waitTime!, fontSize: 20);
                  }
                }
              }
              return Text("none", style: TextStyle(fontSize: MediaQuery.of(context).size.width*.05));
            },
          )
        ],
      ),
    ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BarPage(location: location)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /*LatLng? userLatLng = userLocation.getUserLocation();
    if(userLatLng != null)
      {
        locations.sort((a, b) => (calculateDistanceMeters(a.position.latitude, a.position.longitude, userLatLng.latitude, userLatLng.longitude) - calculateDistanceMeters(b.position.latitude, b.position.longitude, userLatLng.latitude, userLatLng.longitude)).toInt());
      }*/
    return SingleChildScrollView(
        child: BlocBuilder<UserLocationBloc, UserLocationState>(
            builder: (context, state) {
              print("REBUILDING SEARCHES");
              if (state is UserLocationUpdate) {
                print("UPDATING LOCATION");
                locations.sort((a, b) => (calculateDistanceMeters(a.position.latitude, a.position.longitude, state.location.latitude, state.location.longitude) - calculateDistanceMeters(b.position.latitude, b.position.longitude, state.location.latitude, state.location.longitude)).toInt());
                return Column(children: [
                  //GetLocationWidget(),
                  Column(
                    children: <Widget>[
                      for (var location in locations)
                        clickableLocation(location, state.location, context)
                    ],
                  )
                ]);
              }
              else {
                print("no location");
                return Column(children: [
                  //GetLocationWidget(),
                  Column(
                    children: <Widget>[
                      for (var location in locations)
                        clickableLocation(location, null, context)
                    ],
                  )
                ]);
              }
            }),
        );
  }
}