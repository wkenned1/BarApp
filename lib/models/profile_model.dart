import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final int tickets;

  ProfileModel(
      {required this.tickets});

  Map<String, dynamic> toMap() {
    return {
      'tickets': tickets,
    };
  }

  ProfileModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : tickets = doc.data()!["tickets"];

  ProfileModel copyWith({
    required int tickets
  }) {
    return ProfileModel(
        tickets: tickets ?? this.tickets);
  }
}