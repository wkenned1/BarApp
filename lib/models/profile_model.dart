import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final int tickets;
  final bool winner;
  final bool feedbackTicketReceived;
  final String winnerMessage;

  ProfileModel(
      {required this.tickets, required this.winner, required this.feedbackTicketReceived, required this.winnerMessage});

  Map<String, dynamic> toMap() {
    return {
      'tickets': tickets,
      'winner': winner,
      'feedbackTicketReceived': feedbackTicketReceived,
      'winnerMessage': winnerMessage
    };
  }

  ProfileModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : tickets = doc.data()!["tickets"], winner = doc.data()!["winner"], feedbackTicketReceived = doc.data()!["feedbackTicketReceived"], winnerMessage = doc.data()!["winnerMessage"];

  ProfileModel copyWith({
    required int tickets,
    required bool winner,
    required bool feedbackTicketReceived,
    required String winnerMessage
  }) {
    return ProfileModel(
        tickets: tickets ?? this.tickets,
        winner: winner ?? this.winner,
        feedbackTicketReceived: feedbackTicketReceived ?? feedbackTicketReceived,
        winnerMessage: winnerMessage ?? winnerMessage
    );
  }
}