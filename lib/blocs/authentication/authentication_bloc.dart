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
      if (event is AuthenticationStarted) {
        UserModel user = await _authenticationRepository.getCurrentUser().first;
        if (user.uid != "uid") {
          emit(AuthenticationSuccess());
        } else {
          try {
            UserCredential? authUser =
                await _authenticationRepository.signIn(user);
            UserModel updatedUser = user.copyWith(uid: authUser!.user!.uid);
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

  /*_verifyPhoneNumber(String mobile) {
      bool verified = false;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobile,
        verificationCompleted: (PhoneAuthCredential credential) {
          verified = true;
        },
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {},
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
  }*/

}
