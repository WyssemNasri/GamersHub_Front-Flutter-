import 'dart:convert';
import 'package:gamershub/models/AuthModel.dart';
import 'package:http/http.dart' as http;
import 'package:gamershub/Constant/constant.dart';
import 'package:gamershub/models/signupModel.dart';

class AuthService {
Future<String> login(AuthModel authmodel) async {
    try {
      final response = await http.post(
        Uri.parse(login_endpoint),
        headers: {"Content-Type": "application/json"},
        body: authmodel.toJson(),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Failed to log in: ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String> signUp(SignupModel signupModel) async {
    try {
      if (!signupModel.validate()) {
        return "Validation failed: Please check your inputs.";
      }

      final response = await http.post(
        Uri.parse(signup_endpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode(signupModel.toMap()),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Failed to sign up: ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
