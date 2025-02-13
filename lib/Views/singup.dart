import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/GardientButton.dart';
import '../languages/LanguageNotifier.dart';
import '../languages/app_localizations.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            hintColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageNotifier>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("signup")),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  "assets/images/signup.jpg",
                  height: height * 0.34,
                  width: width ,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: height * 0.04),
              CustomTextField(
                labelText: AppLocalizations.of(context).translate("first_name"),
                prefixIcon: Icon(Icons.person, color: theme.iconTheme.color),
                controller: _firstNameController,
              ),
              SizedBox(height: height * 0.04),
              CustomTextField(
                labelText: AppLocalizations.of(context).translate("last_name"),
                prefixIcon: Icon(Icons.person, color: theme.iconTheme.color),
                controller: _lastNameController,
              ),
              SizedBox(height: height * 0.04),
              CustomTextField(
                labelText: AppLocalizations.of(context).translate("email"),
                prefixIcon: Icon(Icons.email, color: theme.iconTheme.color),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: height * 0.04),
              CustomTextField(
                labelText: AppLocalizations.of(context).translate("password"),
                prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
                controller: _passwordController,
                obscureText: _obscurePassword,
              ),
              SizedBox(height: height * 0.04),
              CustomTextField(
                labelText: AppLocalizations.of(context).translate("confirm_password"),
                prefixIcon: Icon(Icons.lock, color: theme.iconTheme.color),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
              ),
              SizedBox(height: height * 0.04),
              TextField(
                controller: _dateController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate("dob"),
                  labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  prefixIcon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
                    onPressed: () => _selectDate(context),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),
              GradientButton(
                text: AppLocalizations.of(context).translate("signup"),
                icon: Icon(Icons.add, color: theme.iconTheme.color),
                onPressed: () {},
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).translate("already_have_account"),
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                  TextButton(
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context).translate("sign in"),
                        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
