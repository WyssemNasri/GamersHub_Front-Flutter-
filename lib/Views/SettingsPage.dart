import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamershub/themes/ThemeNotifier.dart';

import '../FontTheme/FontNotifier.dart';
import '../languages/LanguageNotifier.dart';
import '../languages/app_localizations.dart';  // Add this import for language notifier

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedThemeIndex = 0;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  int _selectedFontIndex = 0;

  List<Color> themeColors = [Colors.blue, Colors.black, Colors.pink];
  List<String> languages = ['English', 'Français', 'العربية'];
  List<String> fontFamilies = ['Roboto', 'GamerFont', 'GirlFont'];


  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedThemeIndex = Provider.of<ThemeNotifier>(context, listen: false).themeIndex;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _selectedFontIndex = prefs.getInt('selectedFontIndex') ?? 0;

    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', _selectedLanguage);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('selectedFontIndex', _selectedFontIndex);

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("settings")),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              title: AppLocalizations.of(context).translate("select_theme "),
              child: DropdownButton<int>(
                value: _selectedThemeIndex,
                onChanged: (int? newValue) {
                  setState(() => _selectedThemeIndex = newValue!);
                  _applyTheme(newValue!);
                },
                items: List.generate(
                  themeColors.length,
                      (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Container(
                      width: 100,
                      height: 15,
                      decoration: BoxDecoration(
                        color: themeColors[index],
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(

              title: AppLocalizations.of(context).translate("select_language"),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() => _selectedLanguage = newValue!);
                  _applyLanguage(newValue!);  // Apply the selected language
                  _savePreferences();
                },
                items: languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _buildCard(
              title: AppLocalizations.of(context).translate("select_font"),
              child: DropdownButton<int>(
                value: _selectedFontIndex,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedFontIndex = newValue!;
                  });
                  _applyFontFamily(newValue!);  // Appliquer la police sélectionnée
                  _savePreferences();
                },
                items: List.generate(
                  fontFamilies.length,
                      (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      fontFamilies[index],
                      style: TextStyle(fontFamily: fontFamilies[index]),
                    ),
                  ),
                ),
              ),
            ),
            _buildCard(
              title: AppLocalizations.of(context).translate("enable_notifications"),
              child: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() => _notificationsEnabled = value);
                  _savePreferences();
                },
                activeColor: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            child,
          ],
        ),
      ),
    );
  }

  void _applyTheme(int themeIndex) {
    Provider.of<ThemeNotifier>(context, listen: false).setTheme(themeIndex);
  }

  // Apply the selected language using LanguageNotifier
  void _applyLanguage(String language) {
    Locale locale;
    switch (language) {
      case 'Français':
        locale = const Locale('fr', '');
        break;
      case 'العربية':
        locale = const Locale('ar', '');
        break;
      default:
        locale = const Locale('en', '');
    }
    Provider.of<LanguageNotifier>(context, listen: false).setLanguage(locale.languageCode);
  }
  void _applyFontFamily(int fontIndex) {
    Provider.of<FontNotifier>(context, listen: false).setFont(fontIndex);
  }
}
