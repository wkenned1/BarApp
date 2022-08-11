part of 'wait_time_report_bloc.dart';

class WaitTimeReportEvent {
  WaitTimeReportEvent({required this.address, required this.waitTime});

  final String address;
  final int waitTime;
}
