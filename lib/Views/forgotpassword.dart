import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamershub/Widgets/CustomTextField.dart';
import '../FontTheme/FontNotifier.dart';
import '../Widgets/GardientButton.dart';
import 'package:gamershub/themes/ThemeNotifier.dart';
import '../languages/app_localizations.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final theme = Provider.of<ThemeNotifier>(context);
    final fontFamily = Provider.of<FontNotifier>(context).fontFamily;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.currentTheme.appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: theme.currentTheme.iconTheme.color,
        ),
      ),
      backgroundColor: theme.currentTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image
            Image.asset("assets/images/forgotpassword.jpg"),
            SizedBox(height: height * 0.04),
            // Email TextField
            CustomTextField(
              labelText: AppLocalizations.of(context).translate("email"),
              prefixIcon: Icon(Icons.email, color: theme.currentTheme.iconTheme.color),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              fontFamily: fontFamily,
            ),
            SizedBox(height: height * 0.04),
            // Send Button
            GradientButton(
              text: AppLocalizations.of(context).translate("send"),
              icon: Icon(Icons.send, color: theme.currentTheme.iconTheme.color),
              onPressed: () {

                String email = emailController.text;
                if (email.isNotEmpty) {

                  print("Send reset link to: $email");
                } else {
                  // Handle empty input
                  print("Please enter an email.");
                }
              },
              fontFamily: fontFamily,
            ),
          ],
        ),
      ),
    );
  }
}
