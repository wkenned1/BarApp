import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:Linez/constants.dart';
import 'package:Linez/globals.dart';
import 'package:Linez/models/image_info_model.dart';
import 'package:Linez/models/profile_model.dart';
import 'package:Linez/models/user_feedback_model.dart';
import 'package:Linez/models/wait_time_location_model.dart';
import 'package:Linez/models/wait_time_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/location_model.dart';
import '../../models/user_model.dart';


class StorageService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> submitLineImage(String imagePath, String address) async {
    var file = File(imagePath);
    if (file != null) {
      //Upload to Firebase
      try {
        final id = UniqueKey().hashCode;
        var snapshot = await _storage.ref()
            .child('linePhotos/${address}/${id}.png')
            .putFile(file);
      }
      catch (err) {
        print("ERROR: ${err.toString()}");
        return false;
      }
      return true;
    } else {
      return false;
    }
  }
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  updateDriverLocation(LatLng location, String driverId) async {
    if(driverId.isEmpty) {
      return;
    }
    print("working 1");
      FirebaseAuth auth = FirebaseAuth.instance;
      var user = auth.currentUser;
    print("working 2");
      if(user != null) {
        if (user!.uid != null) {
          print("working 3");
          DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection("Globals").doc("DriverLocations").get();
          print("working 4");
          if (doc.exists) {
            print("working 5 driver: ${driverId}");
            await _db.collection("Globals").doc("DriverLocations").update({
              driverId: {
                "lat": location.latitude,
                "long": location.longitude
              }
            });
            print("working 6");
          }
        }
      }
  }

  Future<ProfileModel?> getUserProfile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        print("uid: ${user!.uid}");
        DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection("Users").doc(user!.uid).get();
        if(doc.exists){
          print(doc.data());
          return ProfileModel.fromDocumentSnapshot(doc);
        }
        else {
          return null;
        }
      }
    }
    return null;
  }

  addWaitTime(String id, int waitTime) async {
    CollectionReference<Map<String, dynamic>> snap =
        await _db.collection("WaitTimes");
    DocumentSnapshot<Map<String, dynamic>> ref = await snap.doc(id).get();
    if (!ref.exists) {
      await _db.collection("WaitTimes").doc(id).set({"reports": []});
      ref = await _db.collection("WaitTimes").doc(id).get();
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
        .doc(id)
        .set({"reports": reports.map((waitTime) => waitTime.toMap()).toList()});
    return true;
  }

  Future<ImageInfoModel> getImgUrl(String id) async {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _db.collection("WaitTimeImages").doc(id).get();
      String name = snapshot.data()!["imgName"] ?? "";
      if(name.isEmpty) {
        return ImageInfoModel(timeCreated: null, downloadUrl: "");
      }
      final ref = FirebaseStorage.instance.ref().child("linePhotos/${id}/${name}");
      // no need of the file extension, the name will do fine.
      var url = await ref.getDownloadURL();
      DateTime? created = (await ref.getMetadata()).timeCreated;
      if(created == null) {
        return ImageInfoModel(timeCreated: null, downloadUrl: "");
      }
      if (created!
          .difference(DateTime.now().toUtc())
          .inHours.abs() >
          Constants.imageExpiration) {
        return ImageInfoModel(timeCreated: null, downloadUrl: "");
      }
      return ImageInfoModel(timeCreated: created, downloadUrl: url);
  }

  Future<List<WaitTimeModel>> getWaitTimes(String id) async {
    CollectionReference<Map<String, dynamic>> snap =
        await _db.collection("WaitTimes");
    DocumentSnapshot ref = await snap.doc(id).get();
    if (!ref.exists) {
      await _db.collection("WaitTimes").doc(id).set({"reports": []});
      ref = await _db.collection("WaitTimes").doc(id).get();
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

  Future<List<LocationModel>> getLocations() async {
    CollectionReference _collectionRef = _db.collection('Locations');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    var allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    //remove any
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
      if(Constants.customIconsMap.containsKey(model.markerId) && Constants.customSmallIconsMap.containsKey(model.markerId)) {
        ret.add(model);
      }
    }
    return ret;
  }

  /*Future<bool> sendWinnerAddress(String address) async {
    print("debug 1");
    var client = new http.Client();
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    print("debug 2");
    if(user != null) {
      if (user!.uid != null) {
        String token = await user.getIdToken();
        print(token);
        print("debug 3");
        try{
          print("debug 4");
          var response = await client.post(
              Uri.parse("https://us-central1-barapp-5fbe5.cloudfunctions.net/user/sendWinnerAddress/${user!.uid}"),
              headers: {'Authorization': 'Bearer $token',},
              body : {
                'address': address,
              }
          );
          print("debug 5");
          if(response.statusCode == 200 || response.statusCode == 201){
            print("debug 6");
            Map<String, dynamic> temp = jsonDecode(response.body);
            if(temp["addressConfirmed"] as bool){
              print("WINNER: TRUE");
              return true;
            }
          }
          print("debug 7");
        } on Exception catch (err){
          print("Error : $err");
        }
      }
    }
    print("WINNER: FALSE");
    return false;
  }*/

  Future<void> disableWinnerPopup() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection("Users").doc(user!.uid).get();
        if (doc.exists) {
          await _db.collection("Users").doc(user!.uid).set({
            'winnerMessage': Constants.winnerMessageAfterPopup
          },SetOptions(merge: true));
          UserData.winnerMessage = Constants.winnerMessageAfterPopup;
        }
      }
    }
  }

  Future<void> incrementTickets({bool fromFeedback = false}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection("Users").doc(user!.uid).get();
        if(doc.exists){
          int tickets = ProfileModel.fromDocumentSnapshot(doc).tickets;
          if(fromFeedback){
            await _db.collection("Users").doc(user!.uid).set({
              'tickets': tickets + 1,
              'feedbackTicketReceived': true
            },SetOptions(merge: true));
          }
          else {
            await _db.collection("Users").doc(user!.uid).set({
              'tickets': tickets + 1
            },SetOptions(merge: true));
          }
          ProfileModel? profile = await this.getUserProfile();
          if(profile != null) {
            UserData.userTickets = profile.tickets;
          }
        }
      }
    }
  }

  Future<bool> sendFeedback(String message) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        try{
          await _db.collection("UserFeedback").doc().set(UserFeedbackModel(message: message, timestamp: DateTime.now().toUtc(), uid: user!.uid).toMap());
          return true;
        }
        catch(e){
          return false;
        }
      }
    }
    return false;
  }

  Future<List<String>> getComingSoon() async {
    List<String> ret = [];
    DocumentSnapshot<Map<String, dynamic>> doc =
    await _db.collection("ComingSoon").doc("ComingSoon").get();
    if(doc.exists){
      ret = (doc["items"] as List)?.map((item) => item as String)?.toList() ?? [];
    }
    return ret;
  }

  Future<void> deleteProfile() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        try{
          await _db.collection("Users").doc(user!.uid).delete();
        }
        catch(e){
        }
      }
    }
  }

  Future<void> addReportedLocation(String address) async {
    print("deb1");
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    print("deb2");
    if(user != null) {
      if (user!.uid != null) {
        try{
          print("deb3");
          DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection("Users").doc(user!.uid).get();
          print("deb4");
          if (doc.exists) {
            print("deb5");
            List<String>? locations = (doc["reportedLocations"] as List)?.map((item) => item as String)?.toList();
            if(locations != null) {
              print("deb6");
              locations.add(address);
              await _db.collection("Users").doc(user!.uid).set({
                'reportedLocations': locations
              },SetOptions(merge: true));
              print("deb7");
              UserData.winnerMessage = Constants.winnerMessageAfterPopup;
            }
          }
        }
        catch(e){
        }
      }
    }
  }

  Future<DateTime?> getGiveawayTime() async {
    DateTime? dt;
    DocumentSnapshot<Map<String, dynamic>> doc =
    await _db.collection("Globals").doc("GiveawayDate").get();
    if(doc.exists){
      try {
        dt = (doc["date"].toDate());
      }
      catch (e) {
      }
    }
    return dt;
  }

  Future<bool> getRestrictionMode() async {
    bool disabled = false;
    DocumentSnapshot<Map<String, dynamic>> doc =
    await _db.collection("Globals").doc("RestrictionModeNew").get();
    if(doc.exists){
      try {
        disabled = doc["disableAll"] as bool;
      }
      catch (e) {
      }
    }
    return disabled;
  }
}
