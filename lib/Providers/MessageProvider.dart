import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/Message_Model.dart';
import '../services/MessageService.dart';
import '../services/WebSocketService.dart';

class MessageProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  List<Message> messages = [];
  late int _currentUserId;
  late int _currentReceiverId;

  void connect(int userId, int receiverId) async {
    _currentUserId = userId;
    _currentReceiverId = receiverId;

    List<Message> oldMessages = await MessageService().fetchMessages(userId, receiverId);
    messages = oldMessages;

    notifyListeners();

    _webSocketService.connect(userId);
    _webSocketService.onMessageReceived = (data) {
      final jsonData = jsonDecode(data);
      Message newMessage = Message.fromJson(jsonData);

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
