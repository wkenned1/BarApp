part of 'wait_time_report_bloc.dart';

class WaitTimeReportEvent {
  WaitTimeReportEvent({required this.id, required this.waitTime, required this.location});

  final String id;
  final LatLng location;
  final int waitTime;
}
