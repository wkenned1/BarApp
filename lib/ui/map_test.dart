import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../globals.dart';
import '../models/location_model.dart';
import 'bar_page.dart';

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

  LatLng startLocation = LatLng(42.340080, -71.088890);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    addMarkers();
    super.initState();
  }

  addMarkers() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/bar_icon.png",
    );

    List<LocationModel> locations = new List.from(Locations.defaultBars)
      ..addAll(Locations.defaultClubs);

    for (LocationModel location in locations) {
      markers.add(Marker(
          //add start location marker
          markerId: MarkerId(location.markerId),
          position: location.position, //position of marker
          /*infoWindow: InfoWindow(
            //popup info
            title: location.infoWindowTitle,
          ),*/
          //TODO: replace harcoded bit marker with function
          icon: markerbitmap,
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      child: Center(
                          child: Text(
                        location.infoWindowTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )),
                      decoration: BoxDecoration(
                          color: Colors.blue,
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
                                          children: [
                                            Text(
                                              "Wait time: ",
                                              style: TextStyle(fontSize: 20),
                                            ),
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
        GoogleMap(
          myLocationEnabled: false,
          //Map widget from google_maps_flutter package
          zoomGesturesEnabled: true, //enable Zoom in, out on map
          initialCameraPosition: CameraPosition(
            //innital position in map
            target: startLocation, //initial position
            zoom: 14.0, //initial zoom level
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
