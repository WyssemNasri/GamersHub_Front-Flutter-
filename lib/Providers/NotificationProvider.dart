
import 'package:flutter/foundation.dart';
import '../models/NotificationModel.dart';
import '../services/NotificationService.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService notificationService;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  NotificationProvider(this.notificationService);

  Future<void> fetchNotifications() async {
    try {
      _notifications = await notificationService.fetchNotifications();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
