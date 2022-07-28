part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class AuthenticationSuccess extends AuthenticationState {
  final String? email;
  const AuthenticationSuccess({this.email});

  @override
  List<Object?> get props => [email];
}

class AuthenticationFailure extends AuthenticationState {
  @override
  List<Object?> get props => [];
}
