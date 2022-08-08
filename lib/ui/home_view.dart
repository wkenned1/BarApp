import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/database/database_bloc.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Text("welcome"));
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
      if (state is AuthenticationFailure) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeView()),
            (Route<dynamic> route) => false);
      }
    }, buildWhen: ((previous, current) {
      if (current is AuthenticationFailure) {
        return false;
      }
      return true;
    }), builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    context
                        .read<AuthenticationBloc>()
                        .add(AuthenticationSignedOut());
                  })
            ],
            systemOverlayStyle:
                const SystemUiOverlayStyle(statusBarColor: Colors.blue),
            title: Text((state as AuthenticationSuccess).email!),
          ),
          body: BlocBuilder<DatabaseBloc, DatabaseState>(
            builder: (context, state) {
              String? email = (context.read<AuthenticationBloc>().state
                      as AuthenticationSuccess)
                  .email;
              if (email != null) {
                return Text(email);
              } else {
                return Text("user not found");
              }
            },
          ));
    });
  }
}
