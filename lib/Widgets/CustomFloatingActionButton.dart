import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Views/Message.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (context) => Messages()) ) ;},
      backgroundColor: Colors.blue,
      shape: const CircleBorder(),
      child: const Icon(FontAwesomeIcons.facebookMessenger),
    );
  }
}
