import 'package:flutter/material.dart';
import 'package:gamershub/services/AuthentificationService.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/DatePickerField.dart';
import '../Widgets/GardientButton.dart';
import '../models/signup_Model.dart';
import '../Providers/FontNotifier.dart';
import '../Constant/app_localizations.dart';
import 'loginScreen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers = List.generate(7, (_) => TextEditingController());
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signup(SignupModel signupModel) async {
    await AuthService().signUp(signupModel);
  }

  bool _validateForm() => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Consumer<FontNotifier>(
      builder: (context, fontNotifier, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).translate("signup"),
              style: TextStyle(fontFamily: fontNotifier.fontFamily),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/signup.jpg",
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: AppLocalizations.of(context).translate("first_name"),
                      prefixIcon: const Icon(Icons.person),
                      controller: controllers[0],
                      validator: (value) => value!.isEmpty ? AppLocalizations.of(context).translate("enter_first_name") : null,
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: AppLocalizations.of(context).translate("last_name"),
                      prefixIcon: const Icon(Icons.person),
                      controller: controllers[1],
                      validator: (value) => value!.isEmpty ? AppLocalizations.of(context).translate("enter_last_name") : null,
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: AppLocalizations.of(context).translate("email"),
                      prefixIcon: const Icon(Icons.email),
                      controller: controllers[2],
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty ? AppLocalizations.of(context).translate("enter_email") : null,
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: AppLocalizations.of(context).translate("password"),
                      prefixIcon: const Icon(Icons.lock),
                      controller: controllers[3],
                      obscureText: _obscurePassword,
                      validator: (value) => value!.isEmpty ? AppLocalizations.of(context).translate("enter_password") : null,
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: AppLocalizations.of(context).translate("confirm_password"),
                      prefixIcon: const Icon(Icons.lock),
                      controller: controllers[4],
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value != controllers[3].text) {
                          return AppLocalizations.of(context).translate("passwords_not_match");
                        }
                        return null;
                      },
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: AppLocalizations.of(context).translate("phone_number"),
                      prefixIcon: const Icon(Icons.phone),
                      controller: controllers[6],
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? AppLocalizations.of(context).translate("enter_phone_number") : null,
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 16),
                    DatePickerField(
                      controller: controllers[5],
                      labelText: AppLocalizations.of(context).translate("date_of_birth"),
                      fontFamily: fontNotifier.fontFamily,
                      prefixIcon: const Icon(Icons.date_range),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).translate("enter_date_of_birth");
                        }
                        try {
                          DateFormat('yyyy-MM-dd').parse(value);
                        } catch (e) {
                          return AppLocalizations.of(context).translate("invalid_date_format");
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: AppLocalizations.of(context).translate("signup"),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_validateForm()) {
                          SignupModel signupModel = SignupModel(
                            email: controllers[2].text.trim(),
                            password: controllers[3].text.trim(),
                            firstName: controllers[0].text.trim(),
                            lastName: controllers[1].text.trim(),
                            phoneNumber: controllers[6].text.trim(),
                            dayOfBirth: DateFormat('yyyy-MM-dd').parse(controllers[5].text.trim()),
                          );
                          _signup(signupModel);
                        }
                      },
                      fontFamily: fontNotifier.fontFamily,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate("already_have_account"),
                          style: TextStyle(fontFamily: fontNotifier.fontFamily, fontSize: 10),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Loginscreen()),
                          ),
                          child: Text(
                            AppLocalizations.of(context).translate("signin"),
                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: fontNotifier.fontFamily),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
