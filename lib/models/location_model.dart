import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String markerId;
  final LatLng position;
  final String infoWindowTitle;
  final String address;
  final String type;
  const LocationModel({
    required this.markerId,
    required this.position,
    required this.infoWindowTitle,
    required this.address,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'markerId': markerId,
      'position': position,
      'infoWindowTitle': infoWindowTitle,
      'address': address,
      'type': type
    };
  }

  /*UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : markerId = doc.id,
        email = doc.data()!["email"],
        age = doc.data()!["age"],
        displayName = doc.data()!["displayName"];*/

  LocationModel copyWith(
      {required String markerId,
      required LatLng position,
      required String infoWindowTitle,
      required String address,
      required String type}) {
    return LocationModel(
        markerId: this.markerId,
        position: this.position,
        infoWindowTitle: this.infoWindowTitle,
        address: this.address,
        type: this.type);
  }
}
