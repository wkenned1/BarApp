import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/form/form_bloc.dart';
import '../resources/validator.dart';
import 'home_page.dart';
import 'map_test.dart';

class SignUpView extends StatelessWidget {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;

    //context.read<AuthenticationBloc>().add(AuthenticationStarted());
    return HomePage();/*MultiBlocListener(
        listeners: [
          BlocListener<FormBloc, FormAuthState>(listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(content: Text(state.errorMessage)));
            } else if (state.isFormValid && !state.isLoading) {
              context.read<AuthenticationBloc>().add(AuthenticationStarted());
            } else if (state.isFormValidateFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("invalid submission")));
            }
          }),
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationSuccess) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => /*GetLocationWidget()*/ HomePage()),
                );
              }
            },
          ),
        ],
        child: Scaffold(*/

            /*backgroundColor: Color(0xFFFFFFFF),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sign In"),
                      Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02)),
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) =>
                            Validator.validateEmail(email: value!!),
                        decoration: InputDecoration(labelText: "Email"),
                      ),
                      SizedBox(height: size.height * 0.01),
                      TextFormField(
                        controller: _passwordTextController,
                        obscureText: true,
                        validator: (value) =>
                            Validator.validatePassword(password: value!!),
                        decoration: InputDecoration(labelText: "Password"),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<FormBloc>().add(FormSubmitted(
                                    value: Status.signUp,
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text));
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<FormBloc>().add(FormSubmitted(
                                    value: Status.signIn,
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text));
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ]),
              ),
            )*/
            //));
  }
}
