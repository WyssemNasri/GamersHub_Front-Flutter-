import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontNotifier extends ChangeNotifier {
  int _fontIndex = 0;

  // Liste des familles de police disponibles
  final List<String> _fontFamilies = [
    'Roboto',
    'GamerFont',
    'GirlFont',
  ];

  // Getter pour l'index de la police sélectionnée
  int get fontIndex => _fontIndex;

  // Getter pour la famille de police
  String get fontFamily => _fontFamilies[_fontIndex];

  FontNotifier() {
    _loadFontSettings();
  }

  // Charger les paramètres sauvegardés depuis SharedPreferences
  Future<void> _loadFontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontIndex = prefs.getInt('fontIndex') ?? 0; // Valeur par défaut : 'Roboto'
    notifyListeners();
  }

  // Méthode pour changer la police et sauvegarder l'index dans SharedPreferences
  Future<void> setFont(int index) async {
    if (index >= 0 && index < _fontFamilies.length) {
      _fontIndex = index;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('fontIndex', index); // Sauvegarde de l'index de la police
      notifyListeners();
    }
  }

  // Retourner un TextTheme avec la police actuelle
  TextTheme get currentTextTheme {
    return TextTheme(
      bodyLarge: TextStyle(fontFamily: fontFamily),
      bodyMedium: TextStyle(fontFamily: fontFamily),
      displayLarge: TextStyle(fontFamily: fontFamily),
      displayMedium: TextStyle(fontFamily: fontFamily),
      displaySmall: TextStyle(fontFamily: fontFamily),
      headlineMedium: TextStyle(fontFamily: fontFamily),
      headlineSmall: TextStyle(fontFamily: fontFamily),
      titleLarge: TextStyle(fontFamily: fontFamily),
      titleMedium: TextStyle(fontFamily: fontFamily),
      titleSmall: TextStyle(fontFamily: fontFamily),
      labelLarge: TextStyle(fontFamily: fontFamily),
      bodySmall: TextStyle(fontFamily: fontFamily),
      labelSmall: TextStyle(fontFamily: fontFamily),
    );
  }
}
