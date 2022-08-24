import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../globals.dart';
import '../models/location_model.dart';

class MapSample extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapSample> with AutomaticKeepAliveClientMixin {
  GoogleMapController? mapController; //contrller for Google map
  Set<Marker> markers = Set(); //markers for google map

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
        infoWindow: InfoWindow(
          //popup info
          title: location.infoWindowTitle,
        ),
        //TODO: replace harcoded bit marker with function
        icon: markerbitmap, //Icon for Marker
      ));
    }

    setState(() {
      //refresh UI
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
        child: GoogleMap(
      myLocationEnabled: false,
      //Map widget from google_maps_flutter package
      zoomGesturesEnabled: true, //enable Zoom in, out on map
      initialCameraPosition: CameraPosition(
        //innital position in map
        target: startLocation, //initial position
        zoom: 14.0, //initial zoom level
      ),
      markers: markers, //markers to show on map
      mapType: MapType.normal, //map type
      onMapCreated: (controller) {
        controller.setMapStyle(
            '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
        //method called when map is created
        setState(() {
          mapController = controller;
        });
      },
    ));
  }
}
