import 'dart:convert';

class AuthModel {
  final String email;
  final String password;

  AuthModel({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "password": password,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }
}
