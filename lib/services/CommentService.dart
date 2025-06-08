import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gamershub/models/Comment_Model.dart';
import 'package:gamershub/services/SessionManager.dart';
import '../Constant/constant.dart';

class CommentService {
  Future<List<CommentModel>> fetchCommentByPost(int postid) async {
    String? userToken = await SessionManager.loadToken();

    final response = await http.get(
      Uri.parse('$FetchPostComments$postid'),
      headers: {
        'Authorization': 'Bearer $userToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des commentaires');
    }
  }
  Future<void> add_comment (int postid , String content) async{
    String? userToken = await SessionManager.loadToken();
    String ? userId = await SessionManager.loadId() ;

    final response = await http.post(
      Uri.parse(addcomment),
      headers: {
        'Authorization': 'Bearer $userToken',
        'Content-Type': 'application/json',

      },
      body: jsonEncode({
        'userId': userId,
        'postId': postid,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      print("Commentaire ajouté avec succès");
    } else {
      print("Erreur: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception('Échec de l\'ajout du commentaire');
    }

  }
}
