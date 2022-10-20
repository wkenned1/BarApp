import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../models/user_model.dart';
import '../../resources/repositories/authentication_repository_impl.dart';
import '../../resources/repositories/database_repository_impl.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormAuthState> {
  final AuthenticationRepository _authenticationRepository;
  final DatabaseRepository _databaseRepository;
  FormBloc(this._authenticationRepository, this._databaseRepository)
      : super(const FormAuthState(
            email: "example@gmail.com",
            password: "",
            isEmailValid: true,
            isPasswordValid: true,
            isFormValid: false,
            isLoading: false,
            isNameValid: true,
            age: 0,
            isAgeValid: true,
            isFormValidateFailed: false)) {
    on<FormSubmitted>(_onFormSubmitted);
  }

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  bool _isEmailValid(String email) {
    return _emailRegExp.hasMatch(email);
  }

  _onFormSuccess(FormSucceeded event, Emitter<FormAuthState> emit) async {
    emit(state.copyWith(
        isLoading: false, errorMessage: "", isFormSuccessful: true));
  }

  _onFormSubmitted(FormSubmitted event, Emitter<FormAuthState> emit) async {
    emit(state.copyWith(
      isFormSuccessful: false,
      isFormValid: false,
      isFormValidateFailed: false,
      errorMessage: "",
      email: event.email,
      password: event.password,
    ));
    UserModel user = UserModel(
        email: state.email,
        password: state.password,);

    if (event.value == Status.signUp) {
      await _updateUIAndSignUp(event, emit, user);
    } else if (event.value == Status.signIn) {
      await _authenticateUser(event, emit, user);
    }
  }

  //TODO: update password requirements
  _isPasswordValid(String password) {
    return password.length >= 6;
  }

  _isAgeValid(int age) {
    return age >= 18;
  }

  _authenticateUser(
      FormSubmitted event, Emitter<FormAuthState> emit, UserModel user) async {
    emit(state.copyWith(
        errorMessage: "",
        isFormValid:
            _isPasswordValid(state.password) && _isEmailValid(state.email),
        isLoading: true));
    if (state.isFormValid) {
      try {
        UserCredential? authUser = await _authenticationRepository.signIn(user);
        emit(state.copyWith(isLoading: false, errorMessage: ""));
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(
            isLoading: false, errorMessage: e.message, isFormValid: false));
      }
    } else {
      emit(state.copyWith(
          isLoading: false, isFormValid: false, isFormValidateFailed: true));
    }
  }

  _updateUIAndSignUp(
      FormSubmitted event, Emitter<FormAuthState> emit, UserModel user) async {
    emit(state.copyWith(
        errorMessage: "",
        isFormValid:
            _isPasswordValid(state.password) && _isEmailValid(state.email),
        isLoading: true));
    if (state.isFormValid) {
      try {
        UserCredential? authUser = await _authenticationRepository.signUp(user);
        emit(state.copyWith(isLoading: false, errorMessage: ""));
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(
            isLoading: false, errorMessage: e.message, isFormValid: false));
      }
    } else {
      emit(state.copyWith(
          isLoading: false, isFormValid: false, isFormValidateFailed: true));
    }
  }
}
