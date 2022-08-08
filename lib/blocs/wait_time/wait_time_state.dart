part of 'wait_time_bloc.dart';

@immutable
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

class WaitTimeInitialState extends WaitTimeState {
  WaitTimeInitialState() : super();
  List<Object> get props => [];
}

class ReportWaitTimeSuccess extends WaitTimeState {
  ReportWaitTimeSuccess() : super();
  @override
  List<Object> get props => [];
}
