part of 'phone_auth_bloc.dart';

@immutable
abstract class PhoneAuthState {}

class PhoneAuthInitial extends PhoneAuthState {}

class PhoneAuthVerify extends PhoneAuthState {
  final bool successful;
  final String? errorMessage;
  final bool codeSent;
  final bool codeAutoRetrievalTimeout;
  PhoneAuthVerify({required this.successful, this.errorMessage, required this.codeSent, required this.codeAutoRetrievalTimeout});
}

class PhoneSignIn extends PhoneAuthState {
  final ConfirmationResult? confirmationResult;
  final UserCredential? userCredential;
  PhoneSignIn({this.confirmationResult, this.userCredential});
}

class AuthDelete extends PhoneAuthState {
  final bool successful;
  final String? errorMessage;

  AuthDelete({required this.successful, this.errorMessage});
}
