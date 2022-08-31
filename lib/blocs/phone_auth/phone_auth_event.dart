part of 'phone_auth_bloc.dart';

@immutable
abstract class PhoneAuthEvent {}

class PhoneVerifyEvent extends PhoneAuthEvent {
  PhoneVerifyEvent({required this.mobile});

  final String mobile;
}

class PhoneSignInEvent extends PhoneAuthEvent {
  PhoneSignInEvent({required this.mobile});

  final String mobile;
}

class PhoneSignInConfirmEvent extends PhoneAuthEvent {
  PhoneSignInConfirmEvent({required this.code, required this.confirmationResult});

  final String code;
  final ConfirmationResult confirmationResult;
}

class AuthDeleteEvent extends PhoneAuthEvent {
  AuthDeleteEvent();
}

class AuthLogoutEvent extends PhoneAuthEvent {
  AuthLogoutEvent();
}
