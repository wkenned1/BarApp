import 'dart:ffi';

import 'package:bar_app/models/wait_time_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addUserData(UserModel userData) async {
    await _db.collection("Users").doc(userData.uid).set(userData.toMap());
  }

  addWaitTime(String address, int waitTime) async {
    print("ONE");
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    print("TWO");
    CollectionReference<Map<String, dynamic>> snap =
        await _db.collection("WaitTimes");
    print("TWOTWO");
    DocumentSnapshot<Map<String, dynamic>> ref = await snap.doc(address).get();
    if (!ref.exists) {
      await _db.collection("WaitTimes").doc(address).set({"reports": []});
      ref = await _db.collection("WaitTimes").doc(address).get();
    }
    print("THREE");
    List<WaitTimeModel> reports = ref.data()!["reports"].cast<WaitTimeModel>();
    print("FOUR");
    print("UID: " + (uid ?? "null"));
    reports.add(WaitTimeModel(
        waitTime: waitTime, timestamp: DateTime.now(), userId: uid!));
    print("FIVE");
    for (WaitTimeModel model in reports) {
      print("Reports: ${model.waitTime}");
    }
    await _db
        .collection("WaitTimes")
        .doc(address)
        .set({"reports": reports.map((waitTime) => waitTime.toMap()).toList()});
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
}
