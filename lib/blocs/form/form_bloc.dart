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
    //on<FormSucceeded>(_onFormSuccess);
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
    print("SUBMITTED");
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
        password: state.password,
        age: state.age,
        displayName: state.displayName);

    if (event.value == Status.signUp) {
      print("SIGN UP");
      await _updateUIAndSignUp(event, emit, user);
    } else if (event.value == Status.signIn) {
      print("SIGN IN");
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
      FormSubmitted event, Emitter<FormAuthState> emit, UserModel user) async {}

  _updateUIAndSignUp(
      FormSubmitted event, Emitter<FormAuthState> emit, UserModel user) async {
    emit(state.copyWith(
        errorMessage: "",
        isFormValid:
            _isPasswordValid(state.password) && _isEmailValid(state.email),
        isLoading: true));
    print(
        "Email valid: ${_isEmailValid(state.email)} Password valid: ${_isPasswordValid(state.password)}");
    print("PASSWORD: ${state.password}");
    if (state.isFormValid) {
      try {
        UserCredential? authUser = await _authenticationRepository.signUp(user);
        UserModel updatedUser = user.copyWith(
            uid: authUser!.user!.uid, isVerified: authUser.user!.emailVerified);
        await _databaseRepository.saveUserData(updatedUser);
        if (updatedUser.isVerified!) {
          emit(state.copyWith(isLoading: false, errorMessage: ""));
        } else {
          emit(state.copyWith(
              isFormValid: false,
              errorMessage:
                  "Please Verify your email, by clicking the link sent to you by mail.",
              isLoading: false));
        }
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
