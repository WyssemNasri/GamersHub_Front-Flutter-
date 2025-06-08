import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constant/constant.dart';
import '../models/Post_Model.dart';
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

  Future<List<Post>> fetchFriendsPosts() async {
    final userId = await SessionManager.loadId();
    final token = await SessionManager.loadToken();
    if (userId == null || token == null) return [];
    final response = await http.get(
      Uri.parse('$FetchFriendPostes$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Post>.from(data.map((e) => Post.fromJson(e)));
    }
    return [];
  }

  Future<List<Post>> fetchFriendsVIdeos() async {
    final token = await SessionManager.loadToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$FetchVideos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return List<Post>.from(data.map((e) => Post.fromJson(e)));

    }
    return [];
  }
}
