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
        type: "night_club"),
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
        markerId: "OHE",
        position: LatLng(42.341782, -71.087357),
        infoWindowTitle: "OHE",
        address: "52 Gainsborough St, Boston, MA 02115",
        type: "bar"),
    LocationModel(
        markerId: "Lansdowne Pub",
        position: LatLng(42.347359, -71.095078),
        infoWindowTitle: "Lansdowne Pub",
        address: "9 Lansdowne St, Boston, MA 02215",
        type: "bar"),
  ];
}

List<LocationModel> getDefaultBars() {
  return <LocationModel>[
    LocationModel(
        markerId: "Fenway Johnie's",
        position: LatLng(42.346111, -71.099281),
        infoWindowTitle: "Fenway Johnie's",
        address: "96 Brookline Ave, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Loretta's",
        position: LatLng(42.347328, -71.094490),
        infoWindowTitle: "Loretta's",
        address: "1 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Game On!",
        position: LatLng(42.347031, -71.098389),
        infoWindowTitle: "Game On!",
        address: "82 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "OHE",
        position: LatLng(42.341782, -71.087357),
        infoWindowTitle: "OHE",
        address: "52 Gainsborough St, Boston, MA 02115",
        type: "bar"),
    LocationModel(
        markerId: "Lansdowne Pub",
        position: LatLng(42.347359, -71.095078),
        infoWindowTitle: "Lansdowne Pub",
        address: "9 Lansdowne St, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Ned Divine's",
        position: LatLng(42.360040, -71.056240),
        infoWindowTitle: "Ned Divine's",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Bell in Hand",
        position: LatLng(42.361519, -71.057053),
        infoWindowTitle: "Bell in Hand",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Sissy K’s",
        position: LatLng(42.359600, -71.053818),
        infoWindowTitle: "Sissy K’s",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Wild Rover",
        position: LatLng(42.359570, -71.053978),
        infoWindowTitle: "Wild Rover",
        address: "1 S Market St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "Scholars",
        position: LatLng(42.357738, -71.059067),
        infoWindowTitle: "Scholars",
        address: "25 School St, Boston, MA 02108",
        type: "bar"),
    LocationModel(
        markerId: "Hong Kong",
        position: LatLng(42.359558, -71.054108),
        infoWindowTitle: "Hong Kong",
        address: "65 Chatham St, Boston, MA 02109",
        type: "bar"),
    LocationModel(
        markerId: "The Greatest Bar",
        position: LatLng(42.364620, -71.061363),
        infoWindowTitle: "The Greatest Bar",
        address: "262 Friend St, Boston, MA 02114",
        type: "bar"),
    LocationModel(
        markerId: "Lincoln Tavern",
        position: LatLng(42.336349, -71.047539),
        infoWindowTitle: "Lincoln Tavern",
        address: "425 W Broadway, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Loco",
        position: LatLng(42.337060, -71.047690),
        infoWindowTitle: "Loco",
        address: "412 W Broadway, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Capo",
        position: LatLng(42.336079, -71.047020),
        infoWindowTitle: "Capo",
        address: "443 W Broadway, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Fat Baby",
        position: LatLng(42.335030, -71.046230),
        infoWindowTitle: "Fat Baby",
        address: "118 Dorchester St, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Stats",
        position: LatLng(42.335810, -71.045320),
        infoWindowTitle: "Stats",
        address: "77 Dorchester St, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Playwrights",
        position: LatLng(42.335789, -71.038094),
        infoWindowTitle: "Playwrights",
        address: "658 E Broadway, South Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Publico",
        position: LatLng(42.337200, -71.043587),
        infoWindowTitle: "Publico",
        address: "11 Dorchester St, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "L Street Tavern",
        position: LatLng(42.331638, -71.035461),
        infoWindowTitle: "L Street Tavern",
        address: "658 E 8th St, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "The Broadway",
        position: LatLng(42.335918, -71.036232),
        infoWindowTitle: "The Broadway",
        address: "726 E Broadway, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Shenanigans",
        position: LatLng(42.338409, -71.049850),
        infoWindowTitle: "Shenanigans",
        address: "332 W Broadway, Boston, MA 02127",
        type: "bar"),
    LocationModel(
        markerId: "Sunset Cantina",
        position: LatLng(42.350910, -71.116860),
        infoWindowTitle: "Sunset Cantina",
        address: "916 Commonwealth Ave, Boston, MA 02215",
        type: "bar"),
    LocationModel(
        markerId: "Tits",
        position: LatLng(42.353250, -71.132560),
        infoWindowTitle: "Tits",
        address: "161 Brighton Ave, Boston, MA 02134",
        type: "bar"),
    LocationModel(
        markerId: "Buren",
        position: LatLng(42.395401, -71.121696),
        infoWindowTitle: "Buren",
        address: "247 Elm St, Somerville, MA 02144",
        type: "bar"),
    LocationModel(
        markerId: "The Pub",
        position: LatLng(42.399590, -71.111850),
        infoWindowTitle: "The Pub",
        address: "682 Broadway, Somerville, MA 02144",
        type: "bar"),
  ];
}

List<LocationModel> getDefaultClubs() {
  return <LocationModel>[
    LocationModel(
        markerId: "Bijou",
        position: LatLng(42.351238, -71.064209),
        infoWindowTitle: "Bijou",
        address: "51 Stuart St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Hava",
        position: LatLng(42.350731, -71.064728),
        infoWindowTitle: "Hava",
        address: "246 Tremont St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Venu",
        position: LatLng(42.350685, -71.066261),
        infoWindowTitle: "Venu",
        address: "100 Warrenton St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "The Tunnel",
        position: LatLng(42.350842, -71.065659),
        infoWindowTitle: "The Tunnel",
        address: "100 Stuart St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "The Grand",
        position: LatLng(42.353130, -71.047218),
        infoWindowTitle: "The Grand",
        address: "58 Seaport Blvd #300, Boston, MA 02210",
        type: "night_club"),
    LocationModel(
        markerId: "Royale",
        position: LatLng(42.349953, -71.065659),
        infoWindowTitle: "Royale",
        address: "279 Tremont St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Empire",
        position: LatLng(42.353180, -71.045227),
        infoWindowTitle: "Empire",
        address: "1 Marina Park Drive, Boston, MA 02210",
        type: "night_club"),
    LocationModel(
        markerId: "Icon",
        position: LatLng(42.350685, -71.066261),
        infoWindowTitle: "Icon",
        address: "100 Warrenton St, Boston, MA 02116",
        type: "night_club"),
    LocationModel(
        markerId: "Memoire",
        position: LatLng(42.395351, -71.070190),
        infoWindowTitle: "Memoire",
        address: "1 Broadway, Everett, MA 02149",
        type: "night_club"),
    LocationModel(
        markerId: "Big Night Live",
        position: LatLng(42.365780, -71.060692),
        infoWindowTitle: "Big Night Live",
        address: "110 Causeway St, Boston, MA 02114",
        type: "night_club"),
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

    List<LocationModel> locations = new List.from(getDefaultBars())
      ..addAll(getDefaultClubs()); //getDefaultLocations();

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
