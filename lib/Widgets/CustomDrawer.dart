import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userProfileImage;
  final Function() onLogout;
  const CustomDrawer({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userProfileImage,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(userProfileImage),
            ),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
            ),
          ),
          ListTile(
            title: const Text("Déconnexion"),
            onTap: () {

              onLogout();
            },
          ),
        ],
      ),
    );
  }
}
