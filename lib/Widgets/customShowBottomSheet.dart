import 'package:flutter/material.dart';
import 'package:gamershub/models/Like.dart';
import 'package:gamershub/services/LoadImageService.dart';
import 'package:provider/provider.dart';

import '../Constant/app_localizations.dart';
import '../Constant/constant.dart';
import '../Providers/FontNotifier.dart';


void customShowBottomSheet(BuildContext context, List<Like_Model> likes) {
  final loadImageService = LoadImageService();
  final theme = Theme.of(context);
  final localizations = AppLocalizations.of(context);
  final fontNotifier = Provider.of<FontNotifier>(context, listen: false);
  final fontFamily = fontNotifier.fontFamily;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: theme.scaffoldBackgroundColor,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    localizations.translate('likes'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontFamily: fontFamily,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: likes.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final person = likes[index].user;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: FutureBuilder<ImageProvider>(
                      future: loadImageService.fetchImage('${addresse}${person.profilePicUrl}'),
                      builder: (context, snapshot) {
                        return CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: snapshot.hasData
                              ? snapshot.data
                              : const AssetImage('assets/images/default_profile_picture.png') as ImageProvider,
                        );
                      },
                    ),
                    title: Text(
                      '${person.firstName} ${person.lastName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: fontFamily,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    trailing: Icon(Icons.favorite, color: theme.colorScheme.primary),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
