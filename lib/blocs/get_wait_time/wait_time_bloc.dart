import 'dart:async';

import 'package:Linez/models/wait_time_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../constants.dart';
import '../../resources/repositories/database_repository_impl.dart';

part 'wait_time_event.dart';
part 'wait_time_state.dart';

class WaitTimeBloc extends Bloc<WaitTimeEvent, WaitTimeState> {
  final DatabaseRepository _databaseRepository;

  WaitTimeBloc(this._databaseRepository) : super(WaitTimeState(address: "")) {
    on<GetWaitTime>(_getWaitTime);
  }

  _getWaitTime(GetWaitTime event, Emitter<WaitTimeState> emit) async {
    List<WaitTimeModel> waitTimes =
        await _databaseRepository.getWaitTimes(event.address);
    List<int> newWaitTimes = <int>[];
    for (var model in waitTimes) {
      if (DateTime.now().toUtc().difference(model.timestamp).inMinutes <
          Constants.waitTimeReset) {
        //if (DateTime.now().toUtc().hour - model.timestamp.hour < 2) {
        newWaitTimes.add(model.waitTime);
      }
    }
    if (newWaitTimes.length == 0) {
      emit(WaitTimeState(address: event.address));
      return;
    }
    int median = 0;
    newWaitTimes.sort();
    int middle = newWaitTimes.length ~/ 2;
    if (newWaitTimes.length % 2 == 1) {
      median = newWaitTimes[middle];
    } else {
      median =
          ((newWaitTimes[middle - 1] + newWaitTimes[middle]) / 2.0).round();
    }
    emit(WaitTimeState(address: "test", waitTime: median));
  }
}

//for synchronous operations
//TODO: add restrictions for reporting based on time and day (same as restrictions for sending notifications)
Future<WaitTimeState> getWaitTime(GetWaitTime event) async {
  final DatabaseRepository _databaseRepository = DatabaseRepositoryImpl();
  List<WaitTimeModel> waitTimes =
      await _databaseRepository.getWaitTimes(event.address);
  List<int> newWaitTimes = <int>[];
  for (var model in waitTimes) {
    if (DateTime.now().toUtc().difference(model.timestamp).inMinutes <
        Constants.waitTimeReset) {
      //if (DateTime.now().toUtc().hour - model.timestamp.hour < 2) {
      newWaitTimes.add(model.waitTime);
    }
  }
  if (newWaitTimes.length == 0) {
    return WaitTimeState(address: event.address);
  }
  int median = 0;
  newWaitTimes.sort();
  int middle = newWaitTimes.length ~/ 2;
  if (newWaitTimes.length % 2 == 1) {
    median = newWaitTimes[middle];
  } else {
    median = ((newWaitTimes[middle - 1] + newWaitTimes[middle]) / 2.0).round();
  }
  return WaitTimeState(address: "test", waitTime: median);
}
