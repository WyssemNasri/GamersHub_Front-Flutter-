import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/WebSocketService.dart';
class MessageProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  List<Message> messages = [];

  late int _currentUserId;
  late int _currentReceiverId;

  void connect(int userId, int receiverId) {
    _currentUserId = userId;
    _currentReceiverId = receiverId;

    _webSocketService.connect(userId); // Establish connection and subscribe after connection
    _webSocketService.onMessageReceived = (data) {
      final jsonData = jsonDecode(data);
      Message newMessage = Message.fromJson(jsonData);

      // Handle message
      if ((newMessage.senderId == _currentUserId && newMessage.receiverId == _currentReceiverId) ||
          (newMessage.senderId == _currentReceiverId && newMessage.receiverId == _currentUserId)) {
        messages.add(newMessage);
        notifyListeners();
      }
    };
  }


  void sendMessage(Message message) {
    String jsonMessage = jsonEncode(message.toJson());
    _webSocketService.send(jsonMessage);
    messages.add(message);
    notifyListeners();
  }

  void disconnect() {
    _webSocketService.disconnect();
    messages.clear();
  }
}
