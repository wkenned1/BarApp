import 'package:Linez/blocs/user_feedback/user_feedback_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/get_wait_time/wait_time_bloc.dart';
import '../constants.dart';

class UserFeedbackPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final _feedbackController = TextEditingController();

    return Scaffold(
      backgroundColor: Color(Constants.linezBlue),
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
          Padding(padding: EdgeInsets.fromLTRB(10, 10, 10, MediaQuery.of(context).size.height * .4), child:
          Container(
            decoration: BoxDecoration(color: Color(Constants.boxBlue), borderRadius: BorderRadius.all(Radius.circular(10))),
            //color: Color(Constants.boxBlue),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
                  child: Text("Send us feedback!", style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * .08, fontWeight: FontWeight.bold)),
                ),
                Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 20.0),
                  child: Text("Earn an extra raffle ticket by sending us feedback before the giveaway ends. Feel free to send suggestions for new bars or any other feedback",
                    style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * .05),
                  ),),
                Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0), child:
                Center(
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    inputFormatters: [
                      new LengthLimitingTextInputFormatter(140),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(10.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      hintText: "Feedback", // pass the hint text parameter here
                    ),
                    controller: _feedbackController,
                  ),
                ),),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.submitButtonBlue)),
                    child: Text("Submit"),
                    onPressed: (){
                      if(_feedbackController.text.length > 0) {
                        context.read<UserFeedbackBloc>().add(FeedbackSubmitted(
                            message: _feedbackController.text
                        ));
                      }
                    },
                  )
                  ,),
                MultiBlocListener(
                  listeners: [
                    BlocListener<UserFeedbackBloc, UserFeedbackState>(
                        listener: (context, state) {
                          if(state is UserFeedbackSuccess) {
                            Navigator.of(context).pop();
                          }
                          else if(state is UserFeedbackFailure) {
                          }
                        } )],
                  child: Container(),)
              ],
            ),
          )
        )
        );
  }
}