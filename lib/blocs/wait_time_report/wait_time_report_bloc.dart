import 'dart:async';

import 'package:Linez/constants.dart';
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
    int hour = DateTime.now().hour;
    int weekday = DateTime.now().weekday;
    print("Weekday: ${weekday}, Hour: ${hour}");
    if ((hour >= 20 &&
        hour <= 23 &&
        (weekday == 4 ||
            weekday == 5 ||
            weekday == 6 ||
            weekday == 7)) ||
        (hour > 0 &&
            hour <= 2 &&
            (weekday == 5 ||
                weekday == 6 ||
                weekday == 7 ||
                weekday == 1))) {
      try {
        final prefs = await SharedPreferences.getInstance();
        int? ts = prefs.getInt(event.address);
        if (ts != null) {
          final prev_ts = DateTime.fromMillisecondsSinceEpoch(ts).toUtc();
          if (prev_ts
              .difference(DateTime.now().toUtc())
              .inMinutes <
              Constants.waitTimeReset) {
            print("ERROR");
            emit(WaitTimeReportState(
                submitSuccessful: false,
                loading: false,
                errorMessage:
                Constants.waitTimeReportIntervalError));
            return;
          }
        }
        await _databaseRepository.addWaitTime(event.address, event.waitTime);
        int timestamp = DateTime
            .now()
            .toUtc()
            .millisecondsSinceEpoch;
        prefs.setInt(event.address, timestamp);
        print("WORKED");
        emit(WaitTimeReportState(submitSuccessful: true, loading: false));
      } catch (e) {
        print("ERROR 2");
        emit(WaitTimeReportState(
            submitSuccessful: false,
            loading: false,
            errorMessage: e.toString()));
      }
    }
    else {
      emit(WaitTimeReportState(submitSuccessful: false, errorMessage: Constants.waitTimeReportTimeError, loading: false));
    }
  }
}
