import 'dart:ffi';

import 'package:Linez/models/profile_model.dart';
import 'package:Linez/models/wait_time_location_model.dart';
import 'package:Linez/models/wait_time_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/location_model.dart';
import '../../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addUserData(UserModel userData) async {
    await _db.collection("Users").doc(userData.uid).set(userData.toMap());
  }

  addUserProfile(ProfileModel profile) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        await _db.collection("Users").doc(user!.uid).set(profile.toMap());
      }
      else {

      }
    }
  }

  Future<ProfileModel?> getUserProfile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection("Users").doc(user!.uid).get();
        if(doc.exists){
          return ProfileModel.fromDocumentSnapshot(doc);
        }
        else {
          return null;
        }
      }
    }
    return null;
  }

  addWaitTime(String address, int waitTime) async {
    CollectionReference<Map<String, dynamic>> snap =
        await _db.collection("WaitTimes");
    DocumentSnapshot<Map<String, dynamic>> ref = await snap.doc(address).get();
    if (!ref.exists) {
      await _db.collection("WaitTimes").doc(address).set({"reports": []});
      ref = await _db.collection("WaitTimes").doc(address).get();
    }
    List<dynamic> dynamics = List<dynamic>.from(ref.get("reports"));
    List<WaitTimeModel> reports = [];
    for (dynamic r in dynamics) {
      var cast = new Map<String, dynamic>.from(r);
      reports.add(WaitTimeModel(
          waitTime: cast["waitTime"] as int,
          timestamp: cast["timestamp"].toDate()));
    }
    reports.add(
        WaitTimeModel(waitTime: waitTime, timestamp: DateTime.now().toUtc()));
    await _db
        .collection("WaitTimes")
        .doc(address)
        .set({"reports": reports.map((waitTime) => waitTime.toMap()).toList()});
  }

  Future<List<WaitTimeModel>> getWaitTimes(String address) async {
    CollectionReference<Map<String, dynamic>> snap =
        await _db.collection("WaitTimes");
    DocumentSnapshot ref = await snap.doc(address).get();
    if (!ref.exists) {
      await _db.collection("WaitTimes").doc(address).set({"reports": []});
      ref = await _db.collection("WaitTimes").doc(address).get();
    }

    List<dynamic> dynamics = List<dynamic>.from(ref.get("reports"));
    List<WaitTimeModel> reports = [];
    for (dynamic r in dynamics) {
      var cast = new Map<String, dynamic>.from(r);
      reports.add(WaitTimeModel(
          waitTime: cast["waitTime"] as int,
          timestamp: cast["timestamp"].toDate()));
    }
    return reports;
  }

  Future<List<UserModel>> retrieveUserData() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("Users").get();
    return snapshot.docs
        .map((docSnapshot) => UserModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<String> retrieveUserName(UserModel user) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("Users").doc(user.uid).get();
    return snapshot.data()!["displayName"];
  }

  Future<List<LocationModel>> getLocations() async {
    CollectionReference _collectionRef = _db.collection('Locations');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List<LocationModel> ret = [];
    for (var l in allData) {
      Map<String, dynamic> obj = l as Map<String, dynamic>;
      LocationModel model = LocationModel(
          markerId: obj["markerId"] as String,
          position:
              LatLng(obj["latitude"] as double, obj["longitude"] as double),
          infoWindowTitle: obj["infoWindowTitle"] as String,
          address: obj["address"] as String,
          type: obj["type"] as String);
      ret.add(model);
    }
    return ret;
  }
}
