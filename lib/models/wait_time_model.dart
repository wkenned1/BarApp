import 'package:equatable/equatable.dart';

class WaitTimeModel extends Equatable {
  final int waitTime;
  final DateTime timestamp;
  final String userId;

  const WaitTimeModel(
      {required this.waitTime, required this.timestamp, required this.userId});

  Map<String, dynamic> toMap() {
    return {'waitTime': waitTime, 'timestamp': timestamp, 'userId': userId};
  }

  factory WaitTimeModel.fromMap(Map<String, dynamic> map) {
    return WaitTimeModel(
        waitTime: map['waitTime'] as int,
        timestamp: map['timestamp'] as DateTime,
        userId: map['userId'] as String);
  }

  @override
  List<Object?> get props => [];
}
