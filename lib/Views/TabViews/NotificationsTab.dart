import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/NotificationProvider.dart';
import '../../models/NotificationModel.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  Icon _buildIconByType(String type, bool isRead) {
    switch (type.toLowerCase()) {
      case 'PostLiked':
        return Icon(Icons.favorite, color: isRead ? Colors.grey : Colors.red);
      case 'PostCommented':
        return Icon(Icons.comment, color: isRead ? Colors.grey : Colors.blue);
      case 'FriendRequestSent':
        return Icon(Icons.group_add, color: isRead ? Colors.grey : Colors.orange);
      case 'FriendRequestAccepted':
        return Icon(Icons.check_circle, color: isRead ? Colors.grey : Colors.green);
      default:
        return Icon(Icons.notifications, color: isRead ? Colors.grey : Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<void>(
        future: context.read<NotificationProvider>().fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final items = provider.notifications;
              if (items.isEmpty) {
                return const Center(child: Text('Aucune notification'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final notif = items[index];
                  return ListTile(
                    leading: _buildIconByType(notif.type, notif.isRead),
                    title: Text(notif.message),
                    subtitle: Text(
                      '${notif.timestamp.toLocal()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      // Action lorsqu'une notification est cliquée
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
