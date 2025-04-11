// services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constant/constant.dart';
import '../models/Friend.dart';
import '../services/SessionManager.dart';

class UserService {
  Future<Map<String, dynamic>?> fetchUserData() async {
    final userId = await SessionManager.loadId();
    final token = await SessionManager.loadToken();

    if (userId == null || token == null) return null;

    final response = await http.get(
      Uri.parse('$FetchUserinformation$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<List<Friend>> fetchUserFriends() async {
    final userId = await SessionManager.loadId();
    final token = await SessionManager.loadToken();
    if (userId == null || token == null) return [];

    final response = await http.get(
      Uri.parse('$FetchUserFriends$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Friend>.from(data.map((e) => Friend.fromJson(e)));
    }
    return [];
  }
}
