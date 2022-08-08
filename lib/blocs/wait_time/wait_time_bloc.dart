import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../resources/repositories/database_repository_impl.dart';

part 'wait_time_event.dart';
part 'wait_time_state.dart';

class WaitTimeBloc extends Bloc<WaitTimeEvent, WaitTimeState> {
  final DatabaseRepository _databaseRepository;

  WaitTimeBloc(this._databaseRepository) : super(WaitTimeInitialState()) {
    on<GetWaitTime>(_getWaitTime);
    on<ReportWaitTime>(_reportWaitTime);
  }

  _getWaitTime(GetWaitTime event, Emitter<WaitTimeState> emit) async {
    emit(GetWaitTimeState(address: "test", waitTime: 0));
  }

  _reportWaitTime(ReportWaitTime event, Emitter<WaitTimeState> emit) async {
    try {
      await _databaseRepository.addWaitTime(event.address, event.waitTime);
      emit(ReportWaitTimeSuccess());
    } catch (e) {
      print("Wait time report error: " + e.toString());
    }
  }
}
