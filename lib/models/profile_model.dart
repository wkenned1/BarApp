import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final int tickets;
  final bool winner;
  final bool feedbackTicketReceived;
  final String winnerMessage;
  final List<String> reportedLocations;

  ProfileModel(
      {required this.tickets, required this.winner, required this.feedbackTicketReceived, required this.winnerMessage, required this.reportedLocations});

  Map<String, dynamic> toMap() {
    return {
      'tickets': tickets,
      'winner': winner,
      'feedbackTicketReceived': feedbackTicketReceived,
      'winnerMessage': winnerMessage,
      'reportedLocations': reportedLocations
    };
  }

  ProfileModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : tickets = doc.data()!["tickets"], winner = doc.data()!["winner"], feedbackTicketReceived = doc.data()!["feedbackTicketReceived"], winnerMessage = doc.data()!["winnerMessage"], reportedLocations = (doc["reportedLocations"] as List)?.map((item) => item as String)?.toList() ?? [];

  ProfileModel copyWith({
    required int tickets,
    required bool winner,
    required bool feedbackTicketReceived,
    required String winnerMessage,
    required List<String> reportedLocations
  }) {
    return ProfileModel(
        tickets: tickets ?? this.tickets,
        winner: winner ?? this.winner,
        feedbackTicketReceived: feedbackTicketReceived ?? this.feedbackTicketReceived,
        winnerMessage: winnerMessage ?? this.winnerMessage,
        reportedLocations: reportedLocations ?? this.reportedLocations
    );
  }
}