import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/FontNotifier.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsCard({Key? key, required this.title, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontFamily = Provider.of<FontNotifier>(context).fontFamily;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
