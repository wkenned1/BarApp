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
        appBar: AppBar(
          backgroundColor: Color(Constants.linezBlue),
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
          Padding(padding: EdgeInsets.fromLTRB(0, 20.0, 0, 20.0),
          child: Text("Send us feedback!", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .08, fontWeight: FontWeight.bold)),
          ),
      Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 20.0),
        child: Text("Earn an extra raffle ticket by sending us feedback before the giveaway ends. Feel free to send suggestions for new bars or any other feedback",
                style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),
              ),),
      Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0), child:
              Center(
                child: TextFormField(
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(140),
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    hintText: "Feedback", // pass the hint text parameter here
                  ),
                  controller: _feedbackController,
                ),
              ),),
              Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)),
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
        print("failure");
      }
    } )],
    child: Container(),)
            ],
            ),
        )
        );
  }
}