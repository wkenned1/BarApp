import 'dart:math';

import 'package:Linez/globals.dart';
import 'package:Linez/models/location_model.dart';
import 'package:Linez/resources/util/get_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../blocs/get_wait_time/wait_time_bloc.dart';
import '../../blocs/user_location/user_location_bloc.dart';
import '../../constants.dart';
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
  Widget barLocationColumn(LocationModel location, LatLng? userLocation, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(location.markerId, style: TextStyle(fontSize: min(MediaQuery.of(context).size.height * .03, MediaQuery.of(context).size.width * .05), color: Colors.white))),
        if (userLocation != null)
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "${calculateDistanceMiles(userLocation!.latitude, userLocation!.longitude, location.position.latitude, location.position.longitude)} miles away", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .04, color: Colors.white),),)
        else
          Align(
              alignment: Alignment.centerLeft,
              child: Text(location.address.split(",")[0], style: TextStyle(fontSize: min(MediaQuery.of(context).size.height * .024, MediaQuery.of(context).size.width * .04), color: Colors.white))),
      ],
    );
  }

  //creates single row with one location
  //when clicked takes the user to a page to report wait times
  Widget newClickableLocation(
      LocationModel location, LatLng? userLocation, BuildContext context) {
    context.read<WaitTimeBloc>().add(GetWaitTime(
      address: location.address,
    ));
    return GestureDetector(child: Container(
      //margin: const EdgeInsets.fromLTRB(0, 0,10,0),
      //padding: const EdgeInsets.all(3.0),
      width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height/10,
      decoration:
      BoxDecoration(color: Color(Constants.boxBlue), borderRadius: BorderRadius.all(Radius.circular(5))),
      child: ListTile(
        leading:
      (location.type == "bar") ?
        Image.asset("assets/images/bar_icon.png", width: 50, height: 50) :
        Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 0), child: Image.asset("assets/images/club_icon.png", width: 40, height: 40),),
        title: Text(location.markerId, style: TextStyle(fontSize: min(MediaQuery.of(context).size.height * .03, MediaQuery.of(context).size.width * .05), color: Colors.white)),
        subtitle: (userLocation != null) ?
      Text(
        "${calculateDistanceMiles(userLocation!.latitude, userLocation!.longitude, location.position.latitude, location.position.longitude)} miles away", style: TextStyle(fontSize: min(MediaQuery.of(context).size.height * .024, MediaQuery.of(context).size.width * .04), color: Colors.white),) :
        Text(location.address.split(",")[0], style: TextStyle(fontSize: min(MediaQuery.of(context).size.height * .024, MediaQuery.of(context).size.width * .04), color: Colors.white)),
        trailing: FutureBuilder<WaitTimeState>(
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
            return Text("none", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: min(MediaQuery.of(context).size.height * .03, MediaQuery.of(context).size.width * .05),));
          },
        ),
    )
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
      child: Container(
        color: Color(Constants.linezBlue),
        child: BlocBuilder<UserLocationBloc, UserLocationState>(
            builder: (context, state) {
              if (state is UserLocationUpdate) {
                locations.sort((a, b) => (calculateDistanceMeters(a.position.latitude, a.position.longitude, state.location.latitude, state.location.longitude) - calculateDistanceMeters(b.position.latitude, b.position.longitude, state.location.latitude, state.location.longitude)).toInt());
                return Column(children: [
                  //GetLocationWidget(),
                  Column(
                    children: <Widget>[
                      //Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10),),
                      for (var location in locations)
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10), child: newClickableLocation(location, state.location, context))
                    ],
                  )
                ]);
              }
              else {
                return Column(children: [
                  //GetLocationWidget(),
                  Column(
                    children: <Widget>[
                      //Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10),),
                      for (var location in locations)
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 10), child: newClickableLocation(location, null, context))
                    ],
                  )
                ]);
              }
            }),
      ));
  }
}