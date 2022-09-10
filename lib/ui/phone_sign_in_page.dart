import 'package:Linez/globals.dart';
import 'package:Linez/resources/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../blocs/phone_auth/phone_auth_bloc.dart';
import '../constants.dart';
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
  bool ageConfirmed = false;

  static GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
        await DatabaseService().addUserProfile(ProfileModel(tickets: 0, winner: false, feedbackTicketReceived: false, winnerMessage: "", reportedLocations: []));
        UserData.userTickets = 0;
        Navigator.of(context).pop();
      }
      else {
        UserData.userTickets = model.tickets;
        UserData.winner = model.winner;
        UserData.winnerMessage = model.winnerMessage;
        UserData.feedbackTicketReceived = model.feedbackTicketReceived;
        UserData.reportedLocations = model.reportedLocations;
        Navigator.of(context).pop();
      }
    });
  }

  void verifyPhone(BuildContext context) async {
    //check if user is already signed in
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    if(user != null) {
      if (user!.uid != null) {
        Navigator.of(context).pop();
        return;
      }
    }

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
        //key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          backgroundColor: Color(Constants.linezBlue),
          title: Text("Linez"),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(child: Container(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.fromLTRB(0, 20.0, 0, 15.0), child: Text("Sign In", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .08))),
              Container(
                padding: const EdgeInsets.all(8),
                height: 80,
                child:IntlPhoneField(
                  key: _formKey,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(child: Text("I am 18 years or older", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .06),), padding: EdgeInsets.fromLTRB(0, 0, 5,0),),
                  Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                          value: ageConfirmed,
                          onChanged: (bool? event) {
                            print(ageConfirmed);
                            setState(() {
                              ageConfirmed = !ageConfirmed;
                            });
                          }
                      )
                  )
                ],
              ),
              ElevatedButton(onPressed: () {
                if(ageConfirmed) {
                  print("SEND: ${phoneNumber}");
                  verifyPhone(context);
                }
              }, child: Text("Submit"),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue))),
              if(otpVisibility)
                Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0), child: Column(
                  children: [
                    Text("Enter verification code", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .06)),
                    TextFormField(
                      controller: otp,
                      keyboardType: TextInputType.number,
                    ),
                    ElevatedButton(onPressed: () {
                      signIn(context);
                    }, child: Text("submit"),
    style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.linezBlue)))
                  ],
                ),),
            ],
          ),
        ))
    );
  }
}