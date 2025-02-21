import 'package:flutter/material.dart';
import 'package:gamershub/Widgets/CustomFloatingActionButton.dart';
import 'package:gamershub/services/SessionManager.dart';
import '../Widgets/StatusInputWidget.dart';
import 'Loginscreen.dart';
import '../Widgets/CustomAppBar.dart';
import '../Widgets/CustomDrawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _postedStatus = '';

  void _logout() async {
    await SessionManager.destroySession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
    );
  }

  void _handlePostedStatus(String status) {
    setState(() {
      _postedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(
        userName: 'wissem nasri',
        userEmail: 'nasriwissam6@gmail.com',
        userProfileImage: '',
        onLogout: _logout,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusInputWidget(
              onStatusPosted: _handlePostedStatus, // Pass the callback
            ),

          ],
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(),
    );
  }
}
