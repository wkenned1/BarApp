import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UserFeedbackModel {
  final String message;
  final DateTime timestamp;
  final String uid;

  UserFeedbackModel(
      {required this.message, required this.timestamp, required this.uid});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': timestamp,
      'uid': uid
    };
  }

  UserFeedbackModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : message = doc.data()!["message"], timestamp = doc.data()!["timestamp"], uid = doc.data()!["uid"];

  UserFeedbackModel copyWith({
    required String message,
    required DateTime timestamp,
    required String uid
  }) {
    return UserFeedbackModel(
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        uid: uid ?? this.uid

    );
  }
}