import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final int tickets;
  final bool winner;
  final bool feedbackTicketReceived;

  ProfileModel(
      {required this.tickets, required this.winner, required this.feedbackTicketReceived});

  Map<String, dynamic> toMap() {
    return {
      'tickets': tickets,
      'winner': winner,
      'feedbackTicketReceived': feedbackTicketReceived
    };
  }

  ProfileModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : tickets = doc.data()!["tickets"], winner = doc.data()!["winner"], feedbackTicketReceived = doc.data()!["feedbackTicketReceived"];

  ProfileModel copyWith({
    required int tickets,
    required bool winner,
    required bool feedbackTicketReceived
  }) {
    return ProfileModel(
        tickets: tickets ?? this.tickets,
        winner: winner ?? this.winner,
        feedbackTicketReceived: feedbackTicketReceived ?? feedbackTicketReceived
    );
  }
}