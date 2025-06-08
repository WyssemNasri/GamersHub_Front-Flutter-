import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:gamershub/Views/SettingsPage.dart';
import 'package:gamershub/Widgets/CustomFloatingActionButton.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'package:provider/provider.dart';

import '../Providers/FontNotifier.dart';
import '../services/WinkDetector.dart';
import 'Loginscreen.dart';
import 'SearshFriend.dart';
import 'TabViews/FriendRequestsTab.dart';
import 'TabViews/HomeTab.dart';
import 'TabViews/NotificationsTab.dart';
import 'TabViews/VideosTab.dart';
import 'TabViews/ProfileTab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late WinkDetector _winkDetector;

  final List<Widget> _tabs = [
    HomeTab(),
    VideosTab(),
    FriendSearsh(),
    ProfileTab(),
    SettingsPage(),
  ];

  void _logout() async {
    await SessionManager.destroySession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Initialisation et détection de la direction
  void _startHeadDetection() async {
    _winkDetector = WinkDetector();
    await _winkDetector.initialize();

    // Appel toutes les 3 secondes pour détecter la direction de tête
    Timer.periodic(Duration(seconds: 3), (timer) async {
      String? direction = await _winkDetector.startHeadDirectionDetection();
      if (!mounted) return;

      if (direction == 'left') {
        setState(() {
          _selectedIndex = 0;
        });
      } else if (direction == 'right') {
        setState(() {
          _selectedIndex = 1;
        });
      }
      // Tu peux ajouter center/none si besoin
    });
  }

  @override
  void initState() {
    super.initState();
    _startHeadDetection();
  }

  @override
  void dispose() {
    _winkDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Provider.of<FontNotifier>(context).fontFamily;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Container(
            color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/gamershub.png",
                        height: 30,
                        width: 30,
                      ),
                      IconButton(
                        icon: Icon(FeatherIcons.bell,
                            size: 20, color: theme.iconTheme.color),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotificationsTab()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    "GamersHub",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(FeatherIcons.search,
                            size: 20, color: theme.iconTheme.color),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FriendSearch()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(FeatherIcons.logOut,
                            size: 20, color: theme.iconTheme.color),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.unselectedWidgetColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FeatherIcons.home), label: 'Accueil'),
            BottomNavigationBarItem(
                icon: Icon(FeatherIcons.video), label: 'Vidéos'),
            BottomNavigationBarItem(
                icon: Icon(FeatherIcons.userPlus), label: 'Amis'),
            BottomNavigationBarItem(
                icon: Icon(FeatherIcons.user), label: 'Profil'),
            BottomNavigationBarItem(
                icon: Icon(FeatherIcons.settings), label: 'Settings'),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
