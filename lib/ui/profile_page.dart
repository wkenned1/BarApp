import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../globals.dart';

class ProfilePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold),),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          child: Column(children: [
            Text("Profile Page"),
            Text("Tickets: ${UserData.userTickets}")
          ],)
        )
    );
  }
}