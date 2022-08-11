import 'package:equatable/equatable.dart';

class WaitTimeModel extends Equatable {
  final int waitTime;
  final DateTime timestamp;

  const WaitTimeModel({required this.waitTime, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'waitTime': waitTime, 'timestamp': timestamp};
  }

  factory WaitTimeModel.fromMap(Map<String, dynamic> map) {
    return WaitTimeModel(
      waitTime: map['waitTime'] as int,
      timestamp: map['timestamp'] as DateTime,
    );
  }

  @override
  List<Object?> get props => [];
}
