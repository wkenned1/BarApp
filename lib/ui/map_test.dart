import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapSample> {
  GoogleMapController? mapController; //contrller for Google map
  Set<Marker> markers = Set(); //markers for google map

  LatLng startLocation = LatLng(42.340080, -71.088890);

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

    markers.add(Marker(
      //add start location marker
      markerId: MarkerId(startLocation.toString()),
      position: LatLng(42.351238, -71.064209), //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Bijou',
      ),
      icon: markerbitmap, //Icon for Marker
    ));

    setState(() {
      //refresh UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("See Available Bars"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: GoogleMap(
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
