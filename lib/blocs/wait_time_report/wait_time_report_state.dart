part of 'wait_time_report_bloc.dart';

class WaitTimeReportState extends Equatable {
  WaitTimeReportState(
      {required this.submitSuccessful,
      this.errorMessage,
      required this.loading});

  final bool submitSuccessful;
  final String? errorMessage;
  final bool loading;

  /*@override
  List<Object> get props => [submitSuccessful, loading];*/
}
