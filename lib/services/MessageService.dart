import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Constant/constant.dart';
import '../models/Message_Model.dart';
import 'SessionManager.dart';

class MessageService {
  Future<List<Message>> fetchMessages(int userId, int friendId) async {
    String? token = await SessionManager.loadToken() ;
    final response = await http.get(
      Uri.parse('$getAllMessagesEndpoint$userId/$friendId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );


    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Message.fromJson(json)).toList();
    } else if (response.statusCode == 204) {
      return []; // No content
    } else {
      throw Exception('Échec du chargement des messages');
    }
  }

  Future<Message?> fetchLastMessage(int senderId, int receiverId) async {
    final token = await SessionManager.loadToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$getLastMessageEndpoint$senderId/$receiverId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Message.fromJson(data);
      } else {
        print('Erreur de l\'API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération du dernier message: $e');
    }

    return null;
  }
}
