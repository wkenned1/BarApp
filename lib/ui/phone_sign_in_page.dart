import 'package:Linez/globals.dart';
import 'package:Linez/resources/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../blocs/phone_auth/phone_auth_bloc.dart';
import '../models/profile_model.dart';

class PhoneAuthPage extends StatefulWidget {

  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();

}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneNumberController = TextEditingController();
  final otp = TextEditingController();
  String verificationID = "";
  bool otpVisibility = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  String phoneNumber = "";

  void signIn(BuildContext context) async {

    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otp.text);

    await auth.signInWithCredential(credential).then((value) async {
      print("You are logged in successfully");
      ProfileModel? model = await DatabaseService().getUserProfile();
      context.read<PhoneAuthBloc>().add(AuthConfirmLoginEvent());
      if(model == null){
        await DatabaseService().addUserProfile(ProfileModel(tickets: 0, winner: false, feedbackTicketReceived: false, winnerMessage: ""));
        UserData.userTickets = 0;
        Navigator.of(context).pop();
      }
      else {
        UserData.userTickets = model.tickets;
        UserData.winner = model.winner;
        UserData.winnerMessage = model.winnerMessage;
        UserData.feedbackTicketReceived = model.feedbackTicketReceived;
        Navigator.of(context).pop();
      }
    });
  }

  void verifyPhone(BuildContext context) async {
    await auth.verifyPhoneNumber(
      timeout: const Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value){

          print("You are logged in successfully");
          Navigator.of(context).pop();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        otpVisibility = true;
        verificationID = verificationId;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {

      },
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
              Text("Enter phone number"),
              Container(
                padding: const EdgeInsets.all(8),
                height: 80,
                child:IntlPhoneField(
                  decoration: const InputDecoration(
                    counter: Offstage(),
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                  initialCountryCode: 'US',
                  showDropdownIcon: true,
                  dropdownIconPosition:IconPosition.trailing,
                  onChanged: (phone) {
                    phoneNumber = phone.completeNumber;
                    print(phone.completeNumber);
                  },
                ),),
              ElevatedButton(onPressed: () {
                /*context.read<PhoneAuthBloc>().add(PhoneVerifyEvent(
                    mobile: phoneNumber));*/
                print("SEND: ${phoneNumber}");
                verifyPhone(context);
              }, child: Text("Submit")),
              if(otpVisibility) Column(
                children: [
                  Text("code"),
                  TextFormField(
                    controller: otp,
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(onPressed: () {
                    signIn(context);
                  }, child: Text("submit"))
                ],
              )
              /*MultiBlocListener(
                listeners: [
                  BlocListener<PhoneAuthBloc, PhoneAuthState>(listener: (context, state) {
                    if(state is PhoneAuthVerify){
                      print("phone verify state");
                    }
                    else if (state is PhoneSignIn) {
                      print("phone sign in state");
                    }
                    else {
                      print("doesnt know state");
                    }
                  }),
                ], child: Container(),)*/

            ],
          ),
        )
    );
  }
}