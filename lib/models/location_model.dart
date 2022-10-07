import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String markerId;
  final LatLng position;
  final String infoWindowTitle;
  final String address;
  final String type;
  final String? icon;
  const LocationModel({
    required this.markerId,
    required this.position,
    required this.infoWindowTitle,
    required this.address,
    required this.type,
    this.icon
  });

  Map<String, dynamic> toMap() {
    return {
      'markerId': markerId,
      'position': position,
      'infoWindowTitle': infoWindowTitle,
      'address': address,
      'type': type,
      'icon': icon
    };
  }

  /*UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : markerId = doc.id,
        email = doc.data()!["email"],
        age = doc.data()!["age"],
        displayName = doc.data()!["displayName"];*/

  LocationModel copyWith(
      {String? markerId,
      LatLng? position,
      String? infoWindowTitle,
      String? address,
      String? type, String? icon}) {
    return LocationModel(
        markerId: markerId ?? this.markerId,
        position: position ?? this.position,
        infoWindowTitle: infoWindowTitle ?? this.infoWindowTitle,
        address: address ?? this.address,
        type: type ?? this.type,
      icon: icon ?? this.icon
    );
  }
}
