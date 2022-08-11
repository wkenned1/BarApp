import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../resources/repositories/database_repository_impl.dart';
import '../get_wait_time/wait_time_bloc.dart';

part 'wait_time_report_event.dart';
part 'wait_time_report_state.dart';

class WaitTimeReportBloc
    extends Bloc<WaitTimeReportEvent, WaitTimeReportState> {
  final DatabaseRepository _databaseRepository;

  WaitTimeReportBloc(this._databaseRepository)
      : super(WaitTimeReportState(submitSuccessful: false, loading: false)) {
    on<WaitTimeReportEvent>(_reportWaitTime);
  }

  _reportWaitTime(
      WaitTimeReportEvent event, Emitter<WaitTimeReportState> emit) async {
    emit(WaitTimeReportState(submitSuccessful: false, loading: true));
    try {
      await _databaseRepository.addWaitTime(event.address, event.waitTime);
      emit(WaitTimeReportState(submitSuccessful: true, loading: false));
    } catch (e) {
      print("Wait time report error: " + e.toString());
      emit(WaitTimeReportState(
          submitSuccessful: false, loading: false, errorMessage: e.toString()));
    }
  }
}
