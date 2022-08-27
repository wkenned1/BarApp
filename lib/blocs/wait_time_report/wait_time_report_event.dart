part of 'wait_time_report_bloc.dart';

class WaitTimeReportEvent {
  WaitTimeReportEvent({required this.address, required this.waitTime, required this.location});

  final String address;
  final LatLng location;
  final int waitTime;
}
