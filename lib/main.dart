import 'package:flutter/material.dart';
import 'package:gamershub/Views/homeScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Correct import for localization delegates
import 'package:gamershub/themes/ThemeNotifier.dart';
import 'package:gamershub/languages/LanguageNotifier.dart';  // Import LanguageNotifier
import 'FontTheme/FontNotifier.dart';
import 'languages/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),  // Provide ThemeNotifier
        ChangeNotifierProvider(create: (_) => LanguageNotifier()),  // Provide LanguageNotifier
        ChangeNotifierProvider(create: (_) => FontNotifier()),  // Provide FontNotifier
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final language = Provider.of<LanguageNotifier>(context);
    final font = Provider.of<FontNotifier>(context); // Getting the font from FontNotifier

    return MaterialApp(
      locale: language.locale,  // Use the locale from LanguageNotifier
      supportedLocales: const [
        Locale('en', ''),  // English
        Locale('fr', ''),  // French
        Locale('ar', ''),  // Arabic
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,  // Delegate for material components
        GlobalWidgetsLocalizations.delegate,  // Delegate for widget components
        GlobalCupertinoLocalizations.delegate, // Delegate for Cupertino components (iOS style)
        AppLocalizations.delegate, // Custom localization delegate
      ],
      theme: theme.currentTheme,  // Set the theme from ThemeNotifier
      home: Homescreen(),  // Start screen (SplashScreen)
      // Apply the selected font family
      builder: (context, child) {
        return DefaultTextStyle(
          style: TextStyle(fontFamily: font.fontFamily), // Apply the selected font family here
          child: child!,
        );
      },
    );
  }
}
