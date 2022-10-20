part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationSignIn extends AuthenticationEvent {
  final String email;
  final String password;

  AuthenticationSignIn({required this.email, required this.password});

  @override
  List<Object> get props => [];
}

class AuthenticationSignedOut extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}
