// services/post_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constant/constant.dart';
import '../models/Post.dart';
import '../services/SessionManager.dart';

class PostService {
  Future<List<Post>> fetchUserPosts() async {
    final userId = await SessionManager.loadId();
    final token = await SessionManager.loadToken();
    if (userId == null || token == null) return [];

    final response = await http.get(
      Uri.parse('$FetchUserPosts$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Post>.from(data.map((e) => Post.fromJson(e)));
    }
    return [];
  }
}
