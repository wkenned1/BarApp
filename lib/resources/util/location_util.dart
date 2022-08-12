import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationUtil {
  static LatLng? _userLocation;

  LatLng? getUserLocation() {
    return _userLocation;
  }

  void setUserLocation(LocationData location) {
    if (location == null) {
      return;
    }
    if (location.latitude == null || location.longitude == null) {
      return;
    }
    _userLocation = LatLng(location.latitude!, location.longitude!);
  }
}
