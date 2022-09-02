import 'dart:convert';
import 'dart:ffi';

import 'package:Linez/constants.dart';
import 'package:Linez/globals.dart';
import 'package:Linez/models/profile_model.dart';
import 'package:Linez/models/user_feedback_model.dart';
import 'package:Linez/models/wait_time_location_model.dart';
import 'package:Linez/models/wait_time_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<bool> sendWinnerAddress(String address) async {
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
  }

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
}
