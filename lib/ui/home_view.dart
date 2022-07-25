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
            title: Text((state as AuthenticationSuccess).displayName!),
          ),
          body: BlocBuilder<DatabaseBloc, DatabaseState>(
            builder: (context, state) {
              String? displayName = (context.read<AuthenticationBloc>().state
                      as AuthenticationSuccess)
                  .displayName;
              if (state is DatabaseSuccess &&
                  displayName !=
                      (context.read<DatabaseBloc>().state as DatabaseSuccess)
                          .displayName) {
                context.read<DatabaseBloc>().add(DatabaseFetched(displayName));
              }
              if (state is DatabaseInitial) {
                context.read<DatabaseBloc>().add(DatabaseFetched(displayName));
                return const Center(child: CircularProgressIndicator());
              } else if (state is DatabaseSuccess) {
                if (state.listOfUserData.isEmpty) {
                  return const Center(
                    child: Text("No Data"),
                  );
                } else {
                  return Center(
                    child: ListView.builder(
                      itemCount: state.listOfUserData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            title:
                                Text(state.listOfUserData[index].displayName!),
                            subtitle: Text(state.listOfUserData[index].email!),
                            trailing: Text(
                                state.listOfUserData[index].age!.toString()),
                          ),
                        );
                      },
                    ),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ));
    });
  }
}
