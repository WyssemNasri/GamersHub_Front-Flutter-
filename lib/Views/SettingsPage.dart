import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamershub/themes/ThemeNotifier.dart';
import '../FontTheme/FontNotifier.dart';
import '../languages/LanguageNotifier.dart';
import '../languages/app_localizations.dart';
import '../widgets/settings_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedThemeIndex = 0;
  String _selectedLanguage = 'English';
  int _selectedFontIndex = 0;

  final List<Color> themeColors = [Colors.blue, Colors.black, Colors.pink];
  final List<String> languages = ['English', 'Français', 'العربية'];
  final List<String> fontFamilies = ['Roboto', 'GamerFont', 'GirlFont'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _selectedFontIndex = prefs.getInt('selectedFontIndex') ?? 0;
      _selectedThemeIndex = prefs.getInt('selectedThemeIndex') ?? 0;
    });
    _applyTheme(_selectedThemeIndex);
    _applyLanguage(_selectedLanguage);
    _applyFontFamily(_selectedFontIndex);
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', _selectedLanguage);
    await prefs.setInt('selectedFontIndex', _selectedFontIndex);
    await prefs.setInt('selectedThemeIndex', _selectedThemeIndex);
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
        child: ListView(
          children: [
            _buildThemeSelector(context),
            const SizedBox(height: 20),
            _buildLanguageSelector(context),
            const SizedBox(height: 20),
            _buildFontFamilySelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return SettingsCard(
      title: AppLocalizations.of(context).translate("select_theme"),
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
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return SettingsCard(
      title: AppLocalizations.of(context).translate("select_language"),
      child: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (String? newValue) {
          setState(() => _selectedLanguage = newValue!);
          _applyLanguage(newValue!);
          _savePreferences();
        },
        items: languages.map((lang) {
          return DropdownMenuItem<String>(
            value: lang,
            child: Text(lang),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFontFamilySelector(BuildContext context) {
    return SettingsCard(
      title: AppLocalizations.of(context).translate("select_font"),
      child: DropdownButton<int>(
        value: _selectedFontIndex,
        onChanged: (int? newValue) {
          setState(() => _selectedFontIndex = newValue!);
          _applyFontFamily(newValue!);
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
    );
  }

  void _applyTheme(int themeIndex) {
    Provider.of<ThemeNotifier>(context, listen: false).setTheme(themeIndex);
  }

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
