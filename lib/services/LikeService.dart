import 'dart:convert';
import 'package:gamershub/models/Like.dart';
import 'package:http/http.dart' as http;
import 'package:gamershub/services/SessionManager.dart';
import 'package:gamershub/Constant/constant.dart';

class LikeService {
  Future<void> likePost(int postId) async {
    try {
      final token = await SessionManager.loadToken();
      final userId = await SessionManager.loadId();

      if (token == null || userId == null) {
        return;
      }

      final url = Uri.parse('$LikePost');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userid': userId,
          'postid': postId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du like. Code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Like_Model>> getAllLikesInPost(int postId) async {
    final token = await SessionManager.loadToken();
    try {
      final response = await http.get(
        Uri.parse("$getAllLikesBypost/$postId"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Like_Model.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des likes. Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des likes: $e');
    }
  }
}