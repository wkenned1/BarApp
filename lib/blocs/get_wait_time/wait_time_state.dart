part of 'wait_time_bloc.dart';

class WaitTimeState extends Equatable {
  const WaitTimeState({this.waitTime, required this.address});

  final int? waitTime;
  final String address;

  WaitTimeState copyWith({int? waitTime, String? address}) {
    return WaitTimeState(
        waitTime: waitTime ?? this.waitTime, address: address ?? this.address);
  }

  @override
  List<Object?> get props => [waitTime, address];
}

/*@immutable
abstract class WaitTimeState extends Equatable {}

class GetWaitTimeState extends WaitTimeState {
  GetWaitTimeState({
    required this.waitTime,
    required this.address,
  }) : super();

  final int waitTime;
  final String address;

  @override
  List<Object> get props => [];
}

class NoWaitTimeState extends WaitTimeState {
  NoWaitTimeState() : super();
  List<Object> get props => [];
}

class WaitTimeInitialState extends WaitTimeState {
  WaitTimeInitialState() : super();
  List<Object> get props => [];
}

class ReportWaitTimeSuccess extends WaitTimeState {
  ReportWaitTimeSuccess() : super();
  @override
  List<Object> get props => [];
}*/
