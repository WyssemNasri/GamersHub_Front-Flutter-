import 'package:flutter/material.dart';
import 'package:gamershub/Views/Dashbord.dart';
import 'package:gamershub/Views/singup.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/GardientButton.dart';
import '../languages/app_localizations.dart';
import 'forgotpassword.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Utilisation du thème pour le fond
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color), // Icone adaptée au thème
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image
            Image.asset(
              "assets/images/login.png",
              width: width*0.7,
              height: height * 0.4,
              fit: BoxFit.fill,
            ),
            SizedBox(height: height * 0.04),
            // Email TextField
            CustomTextField(
              labelText: AppLocalizations.of(context).translate("email"), // Utilisation de la traduction
              prefixIcon: Icon(Icons.email, color: theme.iconTheme.color), // Icone de champ email
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
            ),
            SizedBox(height: height * 0.04),
            // Password TextField
            CustomTextField(
              labelText: AppLocalizations.of(context).translate("password"), // Utilisation de la traduction
              prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color), // Icone du champ mot de passe
              obscureText: true,
              controller: passwordController,
            ),
            SizedBox(height: height * 0.02),
            // Forgot Password link
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
                      AppLocalizations.of(context).translate("forgot_password"), // Utilisation de la traduction
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color), // Couleur texte du lien
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.04),
            // Login Button
            GradientButton(
              text: AppLocalizations.of(context).translate("login"), // Utilisation de la traduction
              icon: Icon(Icons.login, color: theme.iconTheme.color), // Icone du bouton
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
              },
            ),
            SizedBox(height: height * 0.02),
            // "Don't have an account?" text
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signup()),
              ),
              child: Text(
                AppLocalizations.of(context).translate("dont_have_account"), // Utilisation de la traduction
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16), // Couleur du texte
              ),
            ),
          ],
        ),
      ),
    );
  }
}
