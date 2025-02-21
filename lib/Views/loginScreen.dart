import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gamershub/Views/Dashbord.dart';
import 'package:gamershub/Views/singup.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'package:gamershub/Widgets/CustomTextField.dart';
import 'package:gamershub/Widgets/GardientButton.dart';
import 'package:gamershub/languages/app_localizations.dart';
import 'package:gamershub/services/AuthService.dart';
import 'package:gamershub/Views/forgotpassword.dart';
import 'package:provider/provider.dart';

import '../FontTheme/FontNotifier.dart';
import '../models/AuthModel.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AuthModel authModel = AuthModel(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    try {
      String response = await AuthService().login(authModel);
      print("Response from server: $response");

      Map<String, dynamic> responseData = jsonDecode(response);

      if (responseData.containsKey('token') && responseData.containsKey('userId')) {
        String token = responseData["token"];
        String userId = responseData["userId"];  // Récupérer l'ID utilisateur de la réponse
        await SessionManager.saveToken(token);
        await SessionManager.saveUserId(userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        _showDialog(
          AppLocalizations.of(context).translate("login_failed"),
          AppLocalizations.of(context).translate("invalid_response"),
        );
      }
    } catch (e) {
      print("Unexpected error: $e");
      _showDialog(
        AppLocalizations.of(context).translate("login_failed"),
        AppLocalizations.of(context).translate("error_occurred"),
      );
    }
  }


  void _showDialog(String title, String message) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: theme.textTheme.titleLarge?.color)),
          content: Text(message, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).translate("ok"),
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final fontFamily = Provider.of<FontNotifier>(context).fontFamily;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  "assets/images/login.png",
                  width: width * 0.7,
                  height: height * 0.4,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: height * 0.04),
                CustomTextField(
                  labelText: AppLocalizations.of(context).translate("email"),
                  prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  fontFamily: fontFamily,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate("please_enter_email");
                    }
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return AppLocalizations.of(context).translate("invalid_email_format");
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.04),
                CustomTextField(
                  labelText: AppLocalizations.of(context).translate("password"),
                  prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
                  obscureText: true,
                  controller: passwordController,
                  fontFamily: fontFamily,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context).translate("please_enter_password");
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPassword()),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate("forgot_password"),
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
                GradientButton(
                  text: AppLocalizations.of(context).translate("login"),
                  icon: Icon(Icons.login, color: theme.iconTheme.color),
                  onPressed: _login,
                  fontFamily: fontFamily,
                ),
                SizedBox(height: height * 0.02),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate("dont_have_account"),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 16,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
