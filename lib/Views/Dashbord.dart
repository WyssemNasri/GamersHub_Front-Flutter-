import 'package:flutter/material.dart';
import 'package:gamershub/Views/SettingsPage.dart';
import 'package:gamershub/Widgets/CustomFloatingActionButton.dart';
import 'package:gamershub/services/SessionManager.dart';
import 'Loginscreen.dart';
import 'SearshFriend.dart';
import 'TabViews/FriendRequestsTab.dart';
import 'TabViews/HomeTab.dart';
import 'TabViews/LivesTab.dart';
import 'TabViews/NotificationsTab.dart';
import 'TabViews/VideosTab.dart';
import 'TabViews/ProfileTab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() async {
    await SessionManager.destroySession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GamersHub",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendSearch()),
              );
            },
            icon: const Icon(Icons.person_search_sharp),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),

        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.notifications)),
            Tab(icon: Icon(Icons.live_tv)),
            Tab(icon: Icon(Icons.video_library)),
            Tab(icon: Icon(Icons.person_add)),
            Tab(icon: Icon(Icons.account_circle)), // Profile tab
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeTab(),
          NotificationsTab(),
          LivesTab(),
          VideosTab(),
          FriendSearsh(),
          ProfileTab(),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
