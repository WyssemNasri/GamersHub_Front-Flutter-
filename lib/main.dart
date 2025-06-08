import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Views/Dashbord_View.dart';
import 'Views/homeScreen.dart';
import 'Providers/ThemeNotifier.dart';
import 'Providers/LanguageNotifier.dart';
import 'Providers/FontNotifier.dart';
import 'Providers/MessageProvider.dart';
import 'Providers/NotificationProvider.dart';
import 'services/NotificationService.dart';
import 'Constant/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LanguageNotifier()),
        ChangeNotifierProvider(create: (_) => FontNotifier()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        // <-- Instancier NotificationProvider avec NotificationService
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(NotificationService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>().currentTheme;
    final locale = context.watch<LanguageNotifier>().locale;
    final fontFamily = context.watch<FontNotifier>().fontFamily;

    return MaterialApp(
      locale: locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      theme: theme,
      home: const SplashScreen(),
      builder: (context, child) {
        return DefaultTextStyle(
          style: TextStyle(fontFamily: fontFamily),
          child: child!,
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  Homescreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
