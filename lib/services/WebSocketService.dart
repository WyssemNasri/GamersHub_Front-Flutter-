import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';

import '../Constant/constant.dart';

class WebSocketService {
  late StompClient _stompClient;
  late StompFrame _stompFrame;
  Function(String)? onMessageReceived;

  void connect(int userId) {
    _stompClient = StompClient(
      config: StompConfig(
        url: '$websocket_url?userId=$userId',
        onConnect: (frame) {
          print("Connected to WebSocket");
          // Only subscribe after connection is established
          subscribeToMessages();
        },
        onWebSocketError: (error) {
          print("WebSocket error: $error");
        },
        onDisconnect: (frame) {
          print("Disconnected from WebSocket");
        },
        onStompError: (frame) {
          print("STOMP error: ${frame.body}");
        },
      ),
    );

    _stompClient.activate();  // Activating the client
  }

  void subscribeToMessages() {
    _stompClient.subscribe(
      destination: '/topic/messages',
      callback: (frame) {
        if (frame.body != null) {
          String messageData = frame.body!;
          onMessageReceived?.call(messageData);
        }
      },
    );
  }

  void send(String message) {
    if (_stompClient.connected) {
      _stompClient.send(
        destination: '/app/chat.sendMessage',
        body: message,
      );
    } else {
      print("Not connected to WebSocket");
    }
  }

  void disconnect() {
    _stompClient.deactivate();
  }
}
