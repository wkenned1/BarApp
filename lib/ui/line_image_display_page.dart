import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class LineImageDisplayPage extends StatelessWidget {
  final String downloadUrl;
  final String name;
  final DateTime? created;
  
  LineImageDisplayPage({required this.downloadUrl, required this.name, required this.created});

  @override
  Widget build(BuildContext context) {
    String createdDisplay = created.toString();
    String temp = createdDisplay.split(" ")[1];
    List<String> splitString = temp.split(":");
    int temp2 = int.parse(splitString[0]);
    String display = "${temp2 % 12}:${splitString[1]} ${(temp2 > 12) ? "pm" : "am"}";
    return Scaffold(
        backgroundColor: Colors.black,
        key: GlobalKey<ScaffoldState>(),
        body: GestureDetector(child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Container(
            height: MediaQuery.of(context).size.width*.15,
            width: MediaQuery.of(context).size.width*.15,
            child: FittedBox(
              child:
              new IconButton(
                icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Center(child: Text(name, style: TextStyle(fontSize: MediaQuery.of(context).size.width*.09, color: Colors.white, fontWeight: FontWeight.bold),)),
              if(created != null)
                Center(child: Text("$display", style: TextStyle(fontSize: MediaQuery.of(context).size.width*.07, color: Colors.white, fontWeight: FontWeight.bold),)),
            ],),
                Container(
                  height: MediaQuery.of(context).size.width*.15,
                  width: MediaQuery.of(context).size.width*.15,)
              ],),
          //Center(child: Text(name, style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1, color: Colors.white, fontWeight: FontWeight.bold),)),
           // if(created != null)
            //  Center(child: Text("Posted: $display", style: TextStyle(fontSize: MediaQuery.of(context).size.width*.07, color: Colors.white, fontWeight: FontWeight.bold),)),
            //Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * .05, MediaQuery.of(context).size.width * .05, MediaQuery.of(context).size.width * .05, MediaQuery.of(context).size.width * .05),
             // child:
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(downloadUrl),
            )
                 /* Container(child: Image.network(downloadUrl), decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Color(Constants.boxBlue)),
                  ),)*/
              //)
        ],),
            onTap: (){Navigator.of(context).pop();
            },
    ),
    );
  }
}