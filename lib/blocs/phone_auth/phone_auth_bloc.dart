import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../constants.dart';
import '../../globals.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  FirebaseAuth auth = FirebaseAuth.instance;

  PhoneAuthBloc() : super(PhoneAuthInitial()) {
    on<PhoneVerifyEvent>(_verifyPhone);
    on<PhoneSignInEvent>(_signIn);
    on<PhoneSignInConfirmEvent>(_confirm);
    on<AuthDeleteEvent>(_delete);
    on<AuthConfirmLoginEvent>(_confirmLogin);
    on<AuthLogoutEvent>(_logout);
  }

  Future<void> _verifyPhone(PhoneVerifyEvent event, Emitter<PhoneAuthState> emit) async {
    bool codeSent = false;
    bool timeout = false;
    String? errorCode = null;
    bool verificationCompleted = false;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: event.mobile,
      verificationCompleted: (PhoneAuthCredential credential) async {
        verificationCompleted = true;
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == Constants.invalidPhoneNumber) {
          errorCode = Constants.invalidPhoneNumber;
        }
        else {
          errorCode = Constants.genericError;
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent = true;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        timeout = true;
      },
    );
    emit(PhoneAuthVerify(successful: verificationCompleted, codeSent: codeSent, codeAutoRetrievalTimeout: timeout, errorMessage: errorCode));
  }

  _signIn(PhoneSignInEvent event, Emitter<PhoneAuthState> emit) async {
    try{
      ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(event.mobile);
      emit(PhoneSignIn(confirmationResult: confirmationResult));
    }
    catch(e){

    }
  }

  _confirm(PhoneSignInConfirmEvent event, Emitter<PhoneAuthState> emit) async {
    try {
      UserCredential userCredential = await event.confirmationResult.confirm(event.code);
      emit(PhoneSignIn(userCredential: userCredential));
    }
    catch(e) {

    }
  }

  _delete(AuthDeleteEvent event, Emitter<PhoneAuthState> emit) async {
    var user = auth.currentUser;

    if(user != null){
      try {
        await user.delete();
        emit(AuthDelete(successful: true));
      }
      catch(e){
        print(e.toString());
        emit(AuthDelete(successful: false, errorMessage: e.toString()));
      }
    }
  }

  _logout(AuthLogoutEvent event, Emitter<PhoneAuthState> emit) async {
    var user = auth.currentUser;

    if(user != null){
      try {
        await auth.signOut();
        UserData.userTickets = -1;
        UserData.winner = false;
        UserData.feedbackTicketReceived = false;
        UserData.winnerMessage = "";
        emit(AuthLogout());
    // signed out
    } catch (e){

      }
    // an error
    }
  }

  _confirmLogin(AuthConfirmLoginEvent event, Emitter<PhoneAuthState> emit) async {
    var user = auth.currentUser;

    if(user != null){
      emit(AuthLoginConfirmed());
    }
  }
}

