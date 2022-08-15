import 'dart:async';

import 'package:bar_app/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      int? ts = prefs.getInt(event.address);
      if (ts != null) {
        final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts).toUtc();
        if (prev_ts.difference(DateTime.now().toUtc()).inMinutes <
            Constants.waitTimeReset) {
          print("submitted too soon");
          emit(WaitTimeReportState(
              submitSuccessful: false,
              loading: false,
              errorMessage:
                  "You can only submit one wait time every ${Constants.waitTimeReset} minutes"));
          return;
        }
      }
      await _databaseRepository.addWaitTime(event.address, event.waitTime);
      int timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      prefs.setInt(event.address, timestamp);
      emit(WaitTimeReportState(submitSuccessful: true, loading: false));
    } catch (e) {
      print("Wait time report error: " + e.toString());
      emit(WaitTimeReportState(
          submitSuccessful: false, loading: false, errorMessage: e.toString()));
    }
  }
}
