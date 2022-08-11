import 'dart:async';

import 'package:bar_app/models/wait_time_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../resources/repositories/database_repository_impl.dart';

part 'wait_time_event.dart';
part 'wait_time_state.dart';

class WaitTimeBloc extends Bloc<WaitTimeEvent, WaitTimeState> {
  final DatabaseRepository _databaseRepository;

  WaitTimeBloc(this._databaseRepository) : super(WaitTimeState(address: "")) {
    on<GetWaitTime>(_getWaitTime);
  }

  _getWaitTime(GetWaitTime event, Emitter<WaitTimeState> emit) async {
    print("GETTING WAIT TIME");
    List<WaitTimeModel> waitTimes =
        await _databaseRepository.getWaitTimes(event.address);
    for (var time in waitTimes) {
      print("time: ${time.waitTime}");
    }
    print("GETTING WAIT TIME2");
    print("GETTING WAIT TIME3");
    List<int> newWaitTimes = <int>[];
    print("GETTING WAIT TIME33");
    for (var model in waitTimes) {
      print("GETTING WAIT TIME333");
      print(
          "Time difference: ${DateTime.now().toUtc().hour - model.timestamp.hour < 2}");
      print("Times: ${DateTime.now().toUtc()}, ${model.timestamp.toUtc()}");
      print("GETTING WAIT TIME334");
      print(
          "Time difference in hours: ${DateTime.now().toUtc().hour - model.timestamp.toUtc().hour}");
      if (DateTime.now().toUtc().hour - model.timestamp.hour < 2) {
        print("GETTING WAIT TIME335");
        newWaitTimes.add(model.waitTime);
      }
      print("GETTING WAIT TIME336");
    }
    if (newWaitTimes.length == 0) {
      emit(WaitTimeState(address: event.address));
      return;
    }
    print("GETTING WAIT TIME4");
    int median = 0;
    print("6");
    newWaitTimes.sort();
    print("7");
    int middle = newWaitTimes.length ~/ 2;
    print("Length: ${newWaitTimes.length} , ${newWaitTimes.length % 2}");
    if (newWaitTimes.length % 2 == 1) {
      print("8");
      median = newWaitTimes[middle];
    } else {
      print("9");
      print("middle index: $middle");
      median =
          ((newWaitTimes[middle - 1] + newWaitTimes[middle]) / 2.0).round();
    }
    print("GETTING WAIT TIME5");
    emit(WaitTimeState(address: "test", waitTime: median));
  }
}
