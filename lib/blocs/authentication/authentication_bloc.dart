import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../../resources/repositories/authentication_repository_impl.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc(this._authenticationRepository)
      : super(AuthenticationInitial()) {
    on<AuthenticationEvent>((event, emit) async {
      if (event is AuthenticationSignIn) {
        FirebaseAuth auth = FirebaseAuth.instance;
        final user = auth.currentUser;
        if (user != null && user.uid != null) {
          emit(AuthenticationSuccess());
        } else {
          try {
            UserCredential? authUser =
                await _authenticationRepository.signIn(UserModel(email: event.email, password: event.password));
            emit(AuthenticationSuccess());
          } catch (e) {
            emit(AuthenticationFailure());
          }
        }
      } else if (event is AuthenticationSignedOut) {
        await _authenticationRepository.signOut();
        emit(AuthenticationFailure());
      }
    });
  }
}
