import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'animation_event.dart';
part 'animation_state.dart';

class AnimationBloc extends Bloc<AnimationEvent, AnimationState> {
  static bool animating = false;

  AnimationBloc() : super(AnimationInitial()) {
    on<TicketAnimation>(_ticketAnimation);
  }

  _ticketAnimation(event, emit) async {
    print("anim 1");
    if(!animating) {
      print("anim 2");
      animating = true;
      emit(TicketAnimating());
      await Future.delayed(Duration(seconds: 1));
      animating = false;
      print("anim 3");
    }
  }
}
