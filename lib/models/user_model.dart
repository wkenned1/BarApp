import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  final String? email;
  String? password;

  UserModel(
      {this.email,
      this.password,});
}
