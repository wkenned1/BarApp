import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/phone_auth/phone_auth_bloc.dart';

class LogoutPage extends StatelessWidget {

  //show popup on search page if the user won the givaway
  Widget _buildDeleteDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text("Are you sure?"),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("All of your account information will be deleted."),
          Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0)),
          Center(child: Container(child:
            Row(children: [
              ElevatedButton(onPressed: (){
                context.read<PhoneAuthBloc>().add(AuthDeleteEvent());
                }, child: Text("Yes")),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 5.0, 0)),
              ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
              }, child: Text("No")),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),),
        ],
      ),
      /*actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],*/
    );
  }

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
          child: Column(
            children: [
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
            Center(child: Text("Are you sure you want to log out?", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),)),
            Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Center(child: Container(child:
            Row(children: [
              ElevatedButton(onPressed: (){
                context.read<PhoneAuthBloc>().add(AuthLogoutEvent());
              }, child: Text("Yes")),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 5.0, 0)),
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("No")),
            ], mainAxisAlignment: MainAxisAlignment.center,
            ),
            )),
            Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0), child: Center(
              child: GestureDetector(
                onTap: (){
                  print("tapped");
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildDeleteDialog(context));
                },
                  child: Text("Delete account", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .04, color: Colors.red, decoration: TextDecoration.underline,))),
            ),),
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