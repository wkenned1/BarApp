import 'package:bar_app/models/wait_time_model.dart';
import 'package:equatable/equatable.dart';

class WaitTimeLocationModel extends Equatable {
  final List<WaitTimeModel> reports;

  const WaitTimeLocationModel({required this.reports});

  Map<String, dynamic> toMap() {
    return {'reports': reports};
  }

  factory WaitTimeLocationModel.fromMap(Map<String, dynamic> map) {
    return WaitTimeLocationModel(
      reports: map['reports'] as List<WaitTimeModel>,
    );
  }

  @override
  List<Object?> get props => [];
}
