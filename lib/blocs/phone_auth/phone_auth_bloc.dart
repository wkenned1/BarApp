import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../constants.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  FirebaseAuth auth = FirebaseAuth.instance;

  PhoneAuthBloc() : super(PhoneAuthInitial()) {
    on<PhoneVerifyEvent>(_verifyPhone);
    on<PhoneSignInEvent>(_signIn);
    on<PhoneSignInConfirmEvent>(_confirm);
  }

  Future<void> _verifyPhone(PhoneVerifyEvent event, Emitter<PhoneAuthState> emit) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: event.mobile,
      verificationCompleted: (PhoneAuthCredential credential) async {
        emit(PhoneAuthVerify(successful: true, codeSent: false, codeAutoRetrievalTimeout: false));
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == Constants.invalidPhoneNumber) {
          emit(PhoneAuthVerify(successful: false, codeSent: false, errorMessage: Constants.invalidPhoneNumber, codeAutoRetrievalTimeout: false));
        }
        else {
          emit(PhoneAuthVerify(successful: false, codeSent: false, errorMessage: Constants.genericError, codeAutoRetrievalTimeout: false));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        emit(PhoneAuthVerify(successful: false, codeSent: true, codeAutoRetrievalTimeout: false));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        emit(PhoneAuthVerify(successful: false, codeSent: false, codeAutoRetrievalTimeout: true));
      },
    );
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

  _delete() async {
    var user = auth.currentUser;

    if(user != null){
      try {
        await user.delete();
      }
      catch(e){
        print(e.toString());
      }
    }
  }
}

