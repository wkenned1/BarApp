part of 'wait_time_bloc.dart';

@immutable
abstract class WaitTimeEvent {
  const WaitTimeEvent();

  @override
  List<Object> get props => [];
}

class GetWaitTime extends WaitTimeEvent {
  final String id;

  const GetWaitTime({required this.id});

  @override
  List<Object> get props => [];
}
