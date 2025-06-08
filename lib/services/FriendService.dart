import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constant/constant.dart';
import '../models/Person_Model.dart';
import 'SessionManager.dart';

class FriendService {
  Future<List<Person>> fetchFriends(String userId) async {
    String? token = await SessionManager.loadToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$FetchUserFriends$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((friendData) {
        return Person.fromJson(friendData['receiver']);
      }).toList();
    } else {
      throw Exception('Échec du chargement des amis');
    }
  }
}
