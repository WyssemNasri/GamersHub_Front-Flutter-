import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FloatingActionButton(
      onPressed: null,
      backgroundColor: Colors.blue,
      child: Icon(Icons.message),
      shape: CircleBorder(),
    );
  }
}
