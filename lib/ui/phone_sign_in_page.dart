import 'package:Linez/globals.dart';
import 'package:Linez/resources/services/database_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool consentConfirmed = false;
  String errorMessage = "";
  bool showError = false;

  static GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  String phoneNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(!UserData.admin) {
      FirebaseAnalytics.instance
          .setCurrentScreen(
          screenName: 'SignUpPage'
      );
      FirebaseAnalytics.instance.logEvent(
        name: 'pageView',
        parameters: {
          'page': 'SignUpPage',
        },
      );
    }
  }

  void signIn(BuildContext context) async {
    context.loaderOverlay.show();
    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otp.text);

    await auth.signInWithCredential(credential).then((value) async {
      print("You are logged in successfully");
      ProfileModel? model = await DatabaseService().getUserProfile();
      context.read<PhoneAuthBloc>().add(AuthConfirmLoginEvent());
      if(model == null){
        await DatabaseService().addUserProfile(ProfileModel(tickets: 0, winner: false, feedbackTicketReceived: false, winnerMessage: "", reportedLocations: []));
        UserData.userTickets = 0;
        context.loaderOverlay.hide();
        Navigator.of(context).pop();
      }
      else {
        UserData.userTickets = model.tickets;
        UserData.winner = model.winner;
        UserData.winnerMessage = model.winnerMessage;
        UserData.feedbackTicketReceived = model.feedbackTicketReceived;
        UserData.reportedLocations = model.reportedLocations;
        UserData.admin = model.admin ?? false;
        context.loaderOverlay.hide();
        Navigator.of(context).pop();
      }
    });
  }

  void verifyPhone(BuildContext context) async {
    context.loaderOverlay.show();
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
        context.loaderOverlay.hide();
        /*await auth.signInWithCredential(credential).then((value){
          print("You are logged in successfully");
          Navigator.of(context).pop();
        });*/
      },
      verificationFailed: (FirebaseAuthException e) {
        context.loaderOverlay.hide();
        print(e.message);
        setState(() {
          if(e.message != null){
            errorMessage = e.code + " " + e.message!;
          }
          else {
            errorMessage = e.code;
          }
          //showError = true;
        });

      },
      codeSent: (String verificationId, int? resendToken) {
        context.loaderOverlay.hide();
        otpVisibility = true;
        verificationID = verificationId;
        setState(() {
          //showError = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        context.loaderOverlay.hide();
        setState(() {
          errorMessage = "timed out";
          //showError = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.black, fontSize: MediaQuery.of(context).size.width * .05);
    TextStyle linkStyle = TextStyle(color: Colors.blue, fontSize: MediaQuery.of(context).size.width * .05);
    return LoaderOverlay(child: Scaffold(
        //key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          backgroundColor: Color(Constants.linezBlue),
          title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'BerkshiresWash', fontSize: MediaQuery.of(context).size.width * .07),),
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
                            setState(() {
                              ageConfirmed = !ageConfirmed;
                            });
                          }
                      )
                  )
                ],
              ),
              Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child:
              RichText(text: TextSpan(
                style: defaultStyle,
                children: <TextSpan>[
                  TextSpan(text: "I accept Linez App's "),
                  TextSpan(
                      text: 'Terms of Service',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url = 'https://linezapp.com/terms_conditions_app.html';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                  TextSpan(text: ' and '),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url = 'https://linezapp.com/privacy_app.html';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                ],
              ), textAlign: TextAlign.center, /*style: TextStyle(fontSize: MediaQuery.of(context).size.width * .05),*/)),
              Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                      value: consentConfirmed,
                      onChanged: (bool? event) {
                        setState(() {
                          consentConfirmed = !consentConfirmed;
                        });
                      }
                  )
              ),
              ElevatedButton(onPressed: () {
                if(ageConfirmed && consentConfirmed) {
                  verifyPhone(context);
                }
              }, child: Text("Submit"),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.submitButtonBlue))),
              Visibility(child: Text("ERROR: ${errorMessage}", style: TextStyle(color: Colors.red),), visible: showError,),
              if(otpVisibility)
                Padding(padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0), child: Column(
                  children: [
                    Text("Enter verification code", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .06)),
                    Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child:
                    TextFormField(
                      controller: otp,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                        ),
                        hintText: "Code", // pass the hint text parameter here
                      ),
                    ),),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(Constants.submitButtonBlue)),
                        onPressed: () {
                      signIn(context);
                    }, child: Text("submit"),)
                  ],
                ),),
            ],
          ),
        ))
    ));
  }
}