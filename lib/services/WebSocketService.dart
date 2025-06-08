import 'package:stomp_dart_client/stomp_dart_client.dart';
class WebSocketService {
  late StompClient _stompClient;
  Function(String)? onMessageReceived;
  late int _userId;

  void connect(int userId) {
    _userId = userId;

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: "http://192.168.43.169:8080/ws",
        onConnect: (frame) {
          print("Connected to WebSocket");
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
        heartbeatIncoming: Duration(seconds: 0),
        heartbeatOutgoing: Duration(seconds: 0),
      ),
    );

    _stompClient.activate();
  }

  void subscribeToMessages() {
    _stompClient.subscribe(
      destination: '/user/queue/messages',
      callback: (frame) {
        if (frame.body != null) {
          onMessageReceived?.call(frame.body!);
        }
      },
    );
  }

  void send(String messageJson) {
    if (_stompClient != null && _stompClient!.connected) {
      _stompClient!.send(
        destination: '/app/chat.sendMessage',
        body: messageJson,
      );
      print('Message sent: $messageJson');
    } else {
      print('WebSocket not connected');
    }
  }

  void disconnect() {
    _stompClient.deactivate();
  }
}
