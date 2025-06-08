import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constant/constant.dart';
import '../models/NotificationModel.dart';
import 'package:gamershub/services/SessionManager.dart';

class NotificationService {
  NotificationService();

  Future<List<NotificationModel>> fetchNotifications() async {
    final String? userId = await SessionManager.loadId();
    final String? userToken = await SessionManager.loadToken();
    final uri = Uri.parse('$getAllNotification/$userId');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }
}
