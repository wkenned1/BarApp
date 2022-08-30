import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final int tickets;
  final bool winner;

  ProfileModel(
      {required this.tickets, required this.winner});

  Map<String, dynamic> toMap() {
    return {
      'tickets': tickets,
      'winner': winner
    };
  }

  ProfileModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : tickets = doc.data()!["tickets"], winner = doc.data()!["winner"];

  ProfileModel copyWith({
    required int tickets,
    required bool winner
  }) {
    return ProfileModel(
        tickets: tickets ?? this.tickets,
        winner: winner ?? this.winner
    );
  }
}