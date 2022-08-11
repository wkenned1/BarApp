part of 'wait_time_bloc.dart';

@immutable
abstract class WaitTimeEvent {
  const WaitTimeEvent();

  @override
  List<Object> get props => [];
}

class GetWaitTime extends WaitTimeEvent {
  final String address;

  const GetWaitTime({required this.address});

  @override
  List<Object> get props => [];
}
