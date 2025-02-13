import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gamershub/Views/SettingsPage.dart';
import 'package:gamershub/themes/ThemeNotifier.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        final theme = themeNotifier.currentTheme;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor, // Theme appBar background
            foregroundColor: theme.appBarTheme.foregroundColor, // Theme appBar text/icon color
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings),
                color: theme.iconTheme.color, // Icon color from theme
              ),
            ],
          ),
          body: Container(
            color: theme.scaffoldBackgroundColor, // Background color of the body
            child: Center(
              child: Text(
                'Dashboard Page',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, // Text color from theme
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
