import 'package:flutter/material.dart';

import '../Views/SettingsPage.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  CustomAppBar({Key? key})
      : preferredSize = Size.fromHeight(60.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/gamershub.png') ,
      ),
      title: const Text('accueil'),
      actions: [
        IconButton(
          onPressed: () {

          },
          icon: const Icon(Icons.account_circle),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          icon: const Icon(Icons.settings),
        ),
        IconButton(
          onPressed: () {

          },
          icon: const Icon(Icons.notifications),
        ),
      ],
    );
  }
}
