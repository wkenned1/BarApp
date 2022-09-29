import 'dart:math';

import 'package:Linez/resources/util/get_location.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../blocs/user_location/user_location_bloc.dart';
import '../constants.dart';
import '../globals.dart';
import '../models/location_model.dart';
import 'bar_page.dart';
import 'dart:io' show Platform;

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}

class MapSample extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapSample> with AutomaticKeepAliveClientMixin {
  GoogleMapController? mapController; //contrller for Google map
  Set<Marker> markers = Set(); //markers for google map
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Set<Circle> circles = Set();
  bool hasLocation = false;
  LatLng? userLoc;

  late BitmapDescriptor barMarkerbitmap;
  late BitmapDescriptor clubMarkerbitmap;

  LatLng startLocation = LatLng(42.3428, -71.0675);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    addMarkers();
    super.initState();
  }

  addMarkers() async {
    String bar_icon_path = "assets/images/bar_icon.png";
    String club_icon_path = "assets/images/club_icon.png";
    if (Platform.isIOS) {
      bar_icon_path = "assets/images/bar_icon_small.png";
      club_icon_path = "assets/images/club_icon_small.png";
    }

    List<LocationModel> locations = new List.from(Locations.defaultBars)
      ..addAll(Locations.defaultClubs);

    barMarkerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      bar_icon_path,
    );

    clubMarkerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      club_icon_path,
    );

    for (LocationModel location in locations) {
      BitmapDescriptor? customIconBitMap = null;

      if (Platform.isIOS) {
        if(Constants.customSmallIconsMap.containsKey(location.markerId)){
          customIconBitMap = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            Constants.customSmallIconsMap[location.markerId]!,
          );
        }
      }
      else {
        if(Constants.customIconsMap.containsKey(location.markerId)){
          customIconBitMap = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            Constants.customIconsMap[location.markerId]!,
          );
        }
      }

      markers.add(Marker(
        zIndex: 1,
          //add start location marker
          markerId: MarkerId(location.markerId),
          position: location.position, //position of marker
          /*infoWindow: InfoWindow(
            //popup info
            title: location.infoWindowTitle,
          ),*/
          //TODO: replace harcoded bit marker with function
          icon: customIconBitMap ?? barMarkerbitmap, //(location.type == "bar") ? barMarkerbitmap: clubMarkerbitmap,
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                        location.infoWindowTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: min(20, MediaQuery.of(context).size.width * .05), color: Colors.white),
                      )),
                      decoration: BoxDecoration(
                          color: Color(Constants.linezBlue),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(8),
                          ),
                          border: Border.all(color: Colors.black, width: 2)),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                "I am here",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              Center(
                                  child: FutureBuilder<WaitTimeState>(
                                future: getWaitTime(GetWaitTime(
                                  address: location.address,
                                )),
                                builder: (BuildContext context,
                                    AsyncSnapshot<WaitTimeState> snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data?.waitTime != null) {
                                      if (snapshot.data!.waitTime! >= 0) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            waitTimeDisplay(
                                                snapshot.data!.waitTime!,
                                                fontSize: 20)
                                          ],
                                        );
                                      }
                                    }
                                  }
                                  return Text("No wait time",
                                      style: TextStyle(fontSize: 20));
                                },
                              )),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)),
                                child: Text("Input Time"),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          BarPage(location: location)));
                                },
                              ),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    /*ClipPath(
                      clipper: TriangleClipper(),
                      child: Container(
                        color: Colors.blue,
                        height: 10,
                        width: 20,
                      ),
                    )*/
                  ],
                ),
              ),
              location.position,
            ); //Icon for Marker
          }));
    }
    setState(() {
      //refresh UI
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
          child: Stack(
            children: [
              MultiBlocListener(
                listeners: [
                  BlocListener<UserLocationBloc, UserLocationState>(
                      listener: (context, state) {
                        if(state is UserLocationUpdate) {
                          setState(() {
                            userLoc = state.location;
                            hasLocation = true;
                          });
                        }
                        else {
                          setState(() {
                            userLoc = null;
                            hasLocation = false;
                          });
                        }
                      } )],
                child: Container(width: 0, height: 0,),),
              GoogleMap(
                myLocationButtonEnabled: hasLocation,
                circles: circles,
                myLocationEnabled: hasLocation,
                //Map widget from google_maps_flutter package
                zoomGesturesEnabled: true, //enable Zoom in, out on map
                initialCameraPosition: CameraPosition(
                  //innital position in map
                  target: startLocation, //initial position
                  zoom: 13.0, //initial zoom level
                ),
                markers: markers, //markers to show on map
                mapType: MapType.normal,
                onTap: (position) {
                  _customInfoWindowController.hideInfoWindow!();
                }, //map type
                onMapCreated: (controller) {
                  _customInfoWindowController.googleMapController = controller;
                  controller.setMapStyle(
                      '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
                  //method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
                onCameraMove: (position) {
                  _customInfoWindowController.onCameraMove!();
                },
              ),
              CustomInfoWindow(
                controller: _customInfoWindowController,
                height: 240,
                width: 180,
                offset: 50,
              ),
            ],
          ));
  }
}
