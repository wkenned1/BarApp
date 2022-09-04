import 'package:Linez/resources/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          title: Text("Linez"),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: FutureBuilder<List<String>>(
        future: DatabaseService().getComingSoon(),
    builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          return Container(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(0, 20.0, 0, 15.0),
                  child:  Center(
                      child: Text("Coming soon...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width * .08),)),),
                if(snapshot.hasData)
                  Column(
                  children: <Widget>[
                    for(String item in snapshot.data!)
                      new ListTile(
                        leading: new MyBullet(),
                        title: new Text(item),
                      ),
                    /*new ListTile(
                      leading: new MyBullet(),
                      title: new Text('My first line'),
                    ),
                    new ListTile(
                      leading: new MyBullet(),
                      title: new Text('My second line'),
                    )*/
                  ],
                )
              ],
            ),
          );
    })
    );
  }
}