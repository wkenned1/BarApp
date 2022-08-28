import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneAuthPage extends StatelessWidget {

  final _phoneNumberController = TextEditingController();
  String phoneNumber = "";

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
                    print(phone.completeNumber);
                  },
                ),),
            ],
          ),
        )
    );
  }
}