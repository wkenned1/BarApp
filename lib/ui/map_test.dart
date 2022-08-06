import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location_model.dart';

List<LocationModel> getDefaultLocations() {
  return <LocationModel>[
    LocationModel(
        markerId: "Bijou",
        position: LatLng(42.351238, -71.064209),
        infoWindowTitle: "Bijou",
        address: "51 Stuart St, Boston, MA 02116",
        type: "bar"),
    LocationModel(
        markerId: "Fenway Johnie's",
        position: LatLng(42.346111, -71.099281),
        infoWindowTitle: "Fenway Johnie's",
        address: "96 Brookline Ave, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Loretta's Last Call",
        position: LatLng(42.347328, -71.094490),
        infoWindowTitle: "Loretta's Last Call",
        address: "1 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Game On!",
        position: LatLng(42.347031, -71.098389),
        infoWindowTitle: "Game On!",
        address: "82 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Two Saints Tavern",
        position: LatLng(41.187030, -73.130230),
        infoWindowTitle: "Two Saints Tavern",
        address: "1884 Main St, Stratford, CT 06615",
        type: "bar"),
    LocationModel(
        markerId: "Lansdowne Pub",
        position: LatLng(42.347359, -71.095078),
        infoWindowTitle: "Lansdowne Pub",
        address: "9 Lansdowne St, Boston, MA 02215",
        type: "bar"),
  ];
}

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

    List<LocationModel> locations = getDefaultLocations();

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

    return Scaffold(
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
