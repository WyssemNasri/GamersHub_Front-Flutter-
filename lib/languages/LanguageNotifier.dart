import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');  // Default locale is English

  Locale get locale => _locale;  // Getter for the current locale

  LanguageNotifier() {
    _loadLanguage();
  }

  // Load the saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language') ?? 'en'; // Default to 'en' if no language is saved
    _locale = Locale(langCode); // Update locale
    notifyListeners();  // Notify listeners after updating the locale
  }

  // Change the language and save it in SharedPreferences
  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(langCode);  // Create a new Locale with the new language code
    await prefs.setString('language', langCode);  // Save the language code
    notifyListeners();  // Notify listeners after changing the language
  }
}
