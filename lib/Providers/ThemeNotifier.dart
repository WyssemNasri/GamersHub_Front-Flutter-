import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  int _themeIndex = 1; // Par défaut dark

  int get themeIndex => _themeIndex;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeIndex = prefs.getInt('themeIndex') ?? 1;
    notifyListeners();
  }

  Future<void> setTheme(int themeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    _themeIndex = themeIndex;
    await prefs.setInt('themeIndex', themeIndex);
    notifyListeners();
  }

  ThemeData get currentTheme {
    switch (_themeIndex) {
      case 0:
        return ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
        );
      case 1:
        return ThemeData.dark().copyWith(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        );
      case 2:
        return ThemeData.light().copyWith(
          primaryColor: Colors.pink,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.pink),
        );
      case 3:
        return ThemeData.light().copyWith(
          primaryColor: Colors.red,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.red),
        );
      default:
        return ThemeData.dark();
    }
  }
}
