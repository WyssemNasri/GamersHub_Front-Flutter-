import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamershub/Widgets/CustomTextField.dart';
import '../Widgets/GardientButton.dart';
import 'package:gamershub/languages/LanguageNotifier.dart'; // Import LanguageNotifier
import 'package:gamershub/themes/ThemeNotifier.dart';

import '../languages/app_localizations.dart'; // Import ThemeNotifier

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController emailController = TextEditingController(); // Added controller

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Get the current theme and language from providers
    final theme = Provider.of<ThemeNotifier>(context);
    final language = Provider.of<LanguageNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.currentTheme.appBarTheme.backgroundColor, // Use the theme's AppBar color
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: theme.currentTheme.iconTheme.color, // Use the theme's icon color
        ),
      ),
      backgroundColor: theme.currentTheme.scaffoldBackgroundColor, // Use the theme's background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image
            Image.asset("assets/images/forgotpassword.jpg"), // Ensure image exists
            SizedBox(height: height * 0.04),
            // Email TextField
            CustomTextField(
              labelText: AppLocalizations.of(context).translate("email"), // Translate the label based on selected language
              prefixIcon: Icon(Icons.email, color: theme.currentTheme.iconTheme.color), // Use theme icon color
              controller: emailController, // Added controller to text field
              keyboardType: TextInputType.emailAddress, // Set keyboard type for email
            ),
            SizedBox(
              height: height * 0.04,
            ),
            // Send Button
            GradientButton(
              text: AppLocalizations.of(context).translate("send"), // Translate the button text based on selected language
              icon: Icon(Icons.send, color: theme.currentTheme.iconTheme.color), // Use theme icon color
              onPressed: () {
                // Handle send button action
                String email = emailController.text;
                if (email.isNotEmpty) {
                  // Proceed with sending the reset link
                  print("Send reset link to: $email");
                } else {
                  // Handle empty input
                  print("Please enter an email.");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
