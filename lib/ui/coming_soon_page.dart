import 'package:Linez/resources/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class MyBullet extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 10.0,
      width: 10.0,
      decoration: new BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ComingSoonPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(Constants.linezBlue),
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          backgroundColor: Color(Constants.linezBlue),
          title: Text("Linez"),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body:
        Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, MediaQuery.of(context).size.height * .25), child:
          Container(
          decoration: BoxDecoration(color: Color(Constants.boxBlue), borderRadius: BorderRadius.all(Radius.circular(10))),
          child: FutureBuilder<List<String>>(
              future: DatabaseService().getComingSoon(),
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                return Container(
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(0, 20.0, 0, 15.0),
                        child:  Center(
                            child: Text("Coming soon", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width * .09),)),),
                      if(snapshot.hasData)
                        Column(
                          children: <Widget>[
                            for(String item in snapshot.data!)
                              new ListTile(
                                //leading: new MyBullet(),
                                title: new Text("-    $item", style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * .05)),
                              ),
                          ],
                        )
                    ],
                  ),
                );
              }),
          ))
    );
  }
}