import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/phone_auth/phone_auth_bloc.dart';

class LogoutPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          title: Text("Linez"),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          child: Column(children: [
            Center(child: Text("Are you sure you want to log out?", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)),
            Center(child: Container(child:
            Row(children: [
              ElevatedButton(onPressed: (){
                context.read<PhoneAuthBloc>().add(AuthLogoutEvent());
              }, child: Text("Yes")),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 5.0, 0)),
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("No")),
            ],),
            )),
            MultiBlocListener(listeners: [
              BlocListener<PhoneAuthBloc, PhoneAuthState>(
                listener: (context, state) {
                  if(state is AuthLogout){
                    Navigator.of(context).pop();
                  }
                  else if (state is AuthDelete) {
                    Navigator.of(context).pop();
                  }
                })
            ], child: Container())

          ],),
        )
    );
  }
}