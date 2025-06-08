// lib/models/NotificationModel.dart
class NotificationModel {
  final int id;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['read'] as bool,
      timestamp: DateTime.parse(json['createdAt'] as String),
    );
  }
}
