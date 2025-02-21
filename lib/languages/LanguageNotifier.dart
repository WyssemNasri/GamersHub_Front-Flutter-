import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageNotifier() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }
  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(langCode);
    await prefs.setString('language', langCode);
    notifyListeners();
  }
}
